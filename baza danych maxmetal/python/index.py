from flask import Flask, render_template, request, redirect, url_for, g, make_response,flash
from flask_sqlalchemy import SQLAlchemy
import logging
from sqlalchemy import text
import base64
import smtplib
from email.message import EmailMessage
from datetime import timedelta
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import json
import ssl
import traceback
import os
import datetime
from sqlalchemy.exc import SQLAlchemyError
from flask_wtf import FlaskForm
from wtforms import StringField, DecimalField, TextAreaField, SelectField, FileField, IntegerField, SubmitField
from wtforms.validators import DataRequired, Length
app = Flask(__name__, template_folder="../templates/",static_folder="../static")


app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost/baza_max'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # Maksymalny rozmiar pliku: 16MB
app.config['UPLOAD_EXTENSIONS'] = ['.jpg', '.png', '.gif']
app.secret_key = 'supersecretkey'
app.config['UPLOAD_FOLDER'] = '/../static/img'
db = SQLAlchemy(app)
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in app.config['UPLOAD_EXTENSIONS']

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

try:
    with app.app_context():
        connection = db.engine.connect()  # Uzyskaj połączenie
        connection.execute(text("SELECT 1"))     # Prosta kwerenda, aby sprawdzić połączenie
        logger.info("Połączenie z bazą danych zostało nawiązane pomyślnie.")
        connection.close()                   # Zamknij połączenie
except Exception as e:
    logger.error(f"Nie udało się połączyć z bazą danych: {e}")

class Uzytkownik(db.Model):
    __tablename__ = 'uzytkownicy'
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(255), nullable=False)
    imie = db.Column(db.String(50), nullable=True)
    nazwisko = db.Column(db.String(50), nullable=True)
    haslo = db.Column(db.Text, nullable=False)
    tel = db.Column(db.String(9), nullable=True)
    zdj_profilowe = db.Column(db.LargeBinary, nullable=True)
    id_uprawnienia = db.Column(db.Integer, db.ForeignKey('uprawnienia.id_uprawnienia'), nullable=False, default=2)

    uprawnienia = db.relationship('Uprawnienia', back_populates='uzytkownicy')
    tasma = db.relationship('Tasma', back_populates='pracownik')


class Uprawnienia(db.Model):
    __tablename__ = 'uprawnienia'
    id_uprawnienia = db.Column(db.Integer, primary_key=True)
    nazwa = db.Column(db.String(255), nullable=False)

    uzytkownicy = db.relationship('Uzytkownik', back_populates='uprawnienia')


class Tasma(db.Model):
    __tablename__ = 'tasma'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    nazwa_dostawcy = db.Column(db.String(255), nullable=False)
    nazwa_materialu = db.Column(db.String(255), nullable=False)
    data_z_etykiety_na_kregu = db.Column(db.Date, nullable=False)
    grubosc = db.Column(db.Numeric(10, 2), nullable=False)
    szerokosc = db.Column(db.Numeric(10, 2), nullable=False)
    waga_kregu = db.Column(db.Numeric(10, 2), nullable=False)
    nr_etykieta_paletowa = db.Column(db.String(255), nullable=False)
    nr_z_etykiety_na_kregu = db.Column(db.String(255), nullable=False)
    lokalizacja = db.Column(db.String(255), nullable=False)
    nr_faktury_dostawcy = db.Column(db.String(255), nullable=False)
    data_dostawy = db.Column(db.Date, nullable=False)
    pracownik_id = db.Column(db.Integer, db.ForeignKey('uzytkownicy.id'), nullable=True)

    # Relacja z tabelą 'uzytkownicy'
    pracownik = db.relationship('Uzytkownik', back_populates='tasma')

    def __repr__(self):
        return f"<Tasma {self.id} - {self.nazwa_materialu}>"




@app.before_request
def load_logged_in_user():
    user_id = request.cookies.get('user_id')
    if user_id:
        g.user = Uzytkownik.query.get(int(user_id))
        if g.user and g.user.zdj_profilowe:
            # Kodowanie zdjęcia profilowego do formatu base64
            g.user.zdj_profilowe_base64 = base64.b64encode(g.user.zdj_profilowe).decode('utf-8')
        logger.info(f"Zalogowany użytkownik: {g.user.imie if g.user else 'Brak użytkownika'}")
    else:
        g.user = None







@app.route('/')
def home():
    if not g.user:
        return render_template('login.html', user=g.user)
    resp = make_response(render_template('index.html', user=g.user))
    resp.set_cookie('last', request.path)  # Zapisz ostatni URL

    return resp
@app.route('/go_back')
def go_back():
    last_url = request.cookies.get('last')  # Pobierz ostatni URL z ciasteczka
    if last_url:
        response = make_response(redirect(last_url))  # Przekieruj do ostatniego URL
        response.delete_cookie('last')  # Możesz usunąć ciasteczko po przekierowaniu, jeśli nie jest już potrzebne
        return response
    return "Brak historii do powrotu", 404  # Gdy ciasteczko jest puste



@app.route('/rejestracja_do_bazy', methods=['POST'])
def rejestracja_do_bazy():
    if request.method == 'POST':
        # Odbierz dane z formularza
        email = request.form.get('email')
        haslo = request.form.get('password')
        tel = request.form.get('phone')

        # Debugowanie: sprawdź, co zostało odebrane
        logger.info(f"Odebrane dane: email={email}, tel={tel}, haslo={haslo}")

        # Walidacja danych
        if not email or not haslo or not tel:
            logger.warning("Wszystkie pola są wymagane.")
            return render_template('register.html', error="Wszystkie pola są wymagane.")

        # Sprawdzenie unikalności e-maila
        if Uzytkownik.query.filter_by(email=email).first():
            logger.warning("Użytkownik z tym e-mailem już istnieje.")
            return render_template('register.html', error="Użytkownik z tym e-mailem już istnieje.")

        # Dodanie danych do bazy danych
        nowy_uzytkownik = Uzytkownik(email=email, haslo=generate_password_hash(haslo), tel=tel)
        db.session.add(nowy_uzytkownik)

        try:
            db.session.commit()
            logger.info("Dane zostały pomyślnie zapisane w bazie danych.")
            return redirect(url_for('home'))  # Przekierowanie na stronę główną
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('register.html', error="Wystąpił błąd przy zapisywaniu danych.")
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')

        user = Uzytkownik.query.filter_by(email=email).first()
        logger.info(f"Próba logowania dla emaila: {email}")

        response = None

        if user and check_password_hash(user.haslo, password):
            response = make_response(redirect(url_for('home')))
            remember_me = request.form.get('remember_me')  # Sprawdzenie, czy zaznaczone "zapamiętaj mnie"
            if remember_me:  # Jeśli zaznaczone, ustaw cookie na 30 dni
                max_age = timedelta(days=30)
            else:  # Jeśli nie, cookie wygasa po zamknięciu przeglądarki
                max_age = None
            
            response.set_cookie('user_id', str(user.id), httponly=True, secure=False, samesite='Strict', max_age=max_age)
            logger.info(f"Użytkownik {user.imie} zalogowany pomyślnie.")
            return response
        else:
            logger.warning("Nieudana próba logowania.")
            return render_template('login.html', error="Błędny email lub hasło")

    return render_template('login.html')
@app.route('/logout')
def logout():
    # Tworzenie odpowiedzi przekierowującej na stronę logowania
    response = make_response(redirect(url_for('home')))
    # Usunięcie ciasteczka 'user_id'
    response.set_cookie('user_id', '', expires=0, httponly=True, secure=False, samesite='Strict')
    logger.info("Użytkownik wylogowany.")
    return response   
@app.route('/send', methods=['POST'])
def send():
    # Pobierz dane z formularza
    message = request.form.get('message')
    nowa_cecha = Cechy(nazwa=message)
    db.session.add(nowa_cecha)
    db.session.commit()

    print(f"Wysłano do bazy: {message}")  # Wyświetlenie wiadomości w konsoli
    return render_template("index.html")
@app.route('/contact')
def contact():
    return render_template("contact.html")

@app.route('/feedback', methods=['POST'])
def feedback():
    email = request.form['email']
    comments = request.form['comments']

    # Dane serwera SMTP
    smtp_server = 'poczta.interia.pl'
    smtp_port = 465  # Dla SSL
    sender_email = 'kontakt_lumpstore@interia.pl'
    sender_password = 'LumpStore1@3'

    # Utwórz wiadomość e-mail
    msg = EmailMessage()
    msg['Subject'] = 'Pomoc techniczna LumpStore'
    msg['From'] = sender_email
    msg['To'] = sender_email  # Możesz zmienić na adres obsługi klienta
    msg.set_content(f"E-mail od: {email}\n\nTreść wiadomości:\n{comments}")

    try:
        # Połączenie z serwerem SMTP z SSL
        context = ssl.create_default_context()
        with smtplib.SMTP_SSL(smtp_server, smtp_port, context=context) as smtp:
            smtp.login(sender_email, sender_password)
            smtp.send_message(msg)
        return redirect(url_for('home', success="Wiadomość została wysłana pomyślnie.",user=g.user ))
    except Exception as e:
        error_message = traceback.format_exc()
        print(f"Błąd podczas wysyłania wiadomości: {error_message}")
        return redirect(url_for('home', error="Nie udało się wysłać wiadomości. Skontaktuj się później.",user=g.user))

@app.route('/uzytkownik')
def uzytkownik():
    return render_template("uzytkownik.html", user=g.user)   
import base64
from flask import request, flash, redirect, url_for, render_template, g

@app.route('/update_user', methods=['POST'])
def update_user():
    if not g.user:
        return redirect(url_for('login'))

    imie = request.form.get('imie')
    nazwisko = request.form.get('nazwisko')
    email = request.form.get('email')
    password = request.form.get('password')
    zdj_profilowe = request.files.get('zdj_profilowe')
    tel=request.form.get('tel')
    user = g.user

    # Aktualizacja imienia
    if imie and imie.strip():
        user.imie = imie.strip()
    if nazwisko and nazwisko.strip():
        user.nazwisko = nazwisko.strip()
    if tel and tel.strip():
        if len(tel.strip()) != 9:
            flash('Numer telefonu musi mieć 9 cyfr.', 'error')
            return redirect(url_for('uzytkownik'))
        user.tel = tel.strip()
    # Sprawdzenie i aktualizacja adresu e-mail
    if email:
        existing_user = Uzytkownik.query.filter_by(email=email).first()
        if existing_user and existing_user.id != user.id:
            flash('E-mail jest już zajęty przez innego użytkownika.', 'error')
            return redirect(url_for('uzytkownik'))
        user.email = email

    # Przetwarzanie zdjęcia profilowego
    if zdj_profilowe:
        if not zdj_profilowe.content_type.startswith('image/'):
            flash('Przesłany plik nie jest obrazem.', 'error')
            return redirect(url_for('uzytkownik'))

        try:
            image_data = zdj_profilowe.read()
            user.zdj_profilowe = image_data  # Przechowuj jako binarny
            print("Zdjęcie profilowe zostało zaktualizowane.")  # Debugging
        except Exception as e:
            flash('Wystąpił błąd podczas przetwarzania zdjęcia.', 'error')
            print(f"Błąd podczas przetwarzania zdjęcia: {e}")  # Debugging
            return redirect(url_for('uzytkownik'))

    # Przetwarzanie hasła
    if password and len(password) >= 4:
        user.haslo = generate_password_hash(password)
    elif password:
        flash('Hasło musi mieć co najmniej 4 znaki.', 'error')
        return redirect(url_for('uzytkownik'))

    try:
        db.session.commit()
        flash('Dane użytkownika zostały pomyślnie zaktualizowane.', 'success')
    except Exception as e:
        db.session.rollback()
        print(f"Błąd przy zapisywaniu danych: {e}")  # Debugging
        flash('Wystąpił błąd podczas zapisywania danych.', 'error')

    return redirect(url_for('uzytkownik'))

@app.route('/register')
def register():
     return render_template("register.html")

@app.route('/regulamin')
def regulamin():
    return render_template("regulamin.html")

@app.route('/tasma')
def tasma():
     if not g.user:
        return render_template('login.html', user=g.user)
     tasma = Tasma.query.all()
     
     return render_template("tasma.html",user=g.user,tasma=tasma)
@app.route('/profil')
def profil():
     if not g.user:
        return render_template('login.html', user=g.user)
     return render_template("profil.html",user=g.user)
if __name__ == "__main__":
    app.run(debug=True)