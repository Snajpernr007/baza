from flask import Flask, render_template, request, redirect, url_for, g, make_response,flash,jsonify
from flask_sqlalchemy import SQLAlchemy
import logging
from sqlalchemy import text
import base64
import smtplib
from email.message import EmailMessage
from datetime import timedelta
from datetime import date
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
import threading
import time
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
    login = db.Column(db.String(255), nullable=False)
    
    haslo = db.Column(db.Text, nullable=False)
    id_uprawnienia = db.Column(db.Integer, db.ForeignKey('uprawnienia.id_uprawnienia'), nullable=False, default=2)

    uprawnienia = db.relationship('Uprawnienia', back_populates='uzytkownicy')
    tasma = db.relationship('Tasma', back_populates='pracownik')
    profil = db.relationship('Profil', back_populates='pracownik')

    def __repr__(self):
        return f"<Użytkownik {self.id} - {self.login}>"


class Uprawnienia(db.Model):
    __tablename__ = 'uprawnienia'
    id_uprawnienia = db.Column(db.Integer, primary_key=True)
    nazwa = db.Column(db.String(255), nullable=False)

    uzytkownicy = db.relationship('Uzytkownik', back_populates='uprawnienia')

    def __repr__(self):
        return f"<Uprawnienia {self.id_uprawnienia} - {self.nazwa}>"


class Tasma(db.Model):
    __tablename__ = 'tasma'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
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
    dostawca_id = db.Column(db.Integer, db.ForeignKey('dostawcy.id'), nullable=False)
    szablon_id = db.Column(db.Integer, db.ForeignKey('szablon.id'), nullable=False)

    pracownik = db.relationship('Uzytkownik', back_populates='tasma')
    profil = db.relationship('Profil', back_populates='tasma', cascade='all, delete-orphan')
    dostawca = db.relationship('Dostawcy', back_populates='tasma')
    szablon = db.relationship('Szablon', back_populates='tasma')

    def __repr__(self):
        return f"<Tasma {self.id} - {self.nr_z_etykiety_na_kregu}>"


class Profil(db.Model):
    __tablename__ = 'profil'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    id_tasmy = db.Column(db.Integer, db.ForeignKey('tasma.id'), nullable=False)
    data_produkcji = db.Column(db.Date, nullable=False)
    godz_min_rozpoczecia = db.Column(db.Time, nullable=False)
    godz_min_zakonczenia = db.Column(db.Time, nullable=False)
    zwrot_na_magazyn_kg = db.Column(db.Numeric(10, 2), nullable=True)
    nr_czesci_klienta = db.Column(db.String(50), nullable=False)
    nazwa_klienta_nr_zlecenia_PRODIO = db.Column(db.String(100), nullable=True)
    
    id_pracownika = db.Column(db.Integer, db.ForeignKey('uzytkownicy.id'), nullable=False)

    tasma = db.relationship('Tasma', back_populates='profil')
    pracownik = db.relationship('Uzytkownik', back_populates='profil')

    def __repr__(self):
        return f"<Profil {self.id} - {self.nr_czesci_klienta}>"


class Dostawcy(db.Model):
    __tablename__ = 'dostawcy'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    nazwa = db.Column(db.String(255), nullable=False)

    tasma = db.relationship('Tasma', back_populates='dostawca')

    def __repr__(self):
        return f"<Dostawca {self.id} - {self.nazwa}>"


class Szablon(db.Model):
    __tablename__ = 'szablon'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    nazwa = db.Column(db.String(255), nullable=False)
    rodzaj = db.Column(db.String(255), nullable=False)
    grubosc_i_oznaczenie_ocynku = db.Column(db.String(255), nullable=False)
    grubosc = db.Column(db.Numeric(10, 2), nullable=False)
    szerokosc = db.Column(db.Numeric(10, 2), nullable=False)

    tasma = db.relationship('Tasma', back_populates='szablon')

    def __repr__(self):
        return f"<Szablon {self.id} - {self.rodzaj}>"

def zapisz_wszystkie_dane_do_plikow():
    while True:
        for i in range(5):
            zapisz_do_pliku_sql(i + 1)
            time.sleep(14400)  # Czekaj 4 godziny (14400 sekund)

def zapisz_do_pliku_sql(numer_pliku):
    """Zapisz dane z tabel do jednego pliku SQL w formacie INSERT jako kopię zapasową."""
    tabelki = ['uprawnienia', 'uzytkownicy', 'tasma', 'profil']  # Upewnij się, że klucze obce są poprawnie zapisane
    nazwa_pliku = f'kopie_zapasowe_bazy_{numer_pliku}.sql'

    try:
        with app.app_context():
            with open(nazwa_pliku, 'w', encoding='utf-8') as plik:
                # Zapisz CREATE TABLE dla każdej tabeli
                for tabela in tabelki:
                    # Pobierz definicję tabeli
                    create_table_query = f"SHOW CREATE TABLE {tabela};"
                    create_table_result = db.session.execute(text(create_table_query))
                    create_table_statement = create_table_result.fetchone()[1]  # Pobierz definicję CREATE TABLE

                    # Zapisz CREATE TABLE
                    plik.write(f"{create_table_statement};\n\n")

                # Zapisz dane do pliku
                for tabela in tabelki:
                    query = db.session.execute(text(f"SELECT * FROM {tabela}"))
                    wyniki = query.fetchall()  # Pobranie wyników
                    kolumny = query.keys()  # Uzyskanie nazw kolumn

                    if wyniki:
                        plik.write(f"-- Dane z tabeli {tabela}\n")
                        for wiersz in wyniki:
                            wartosci = ', '.join(
                                [f"'{str(val).replace('\'', '\'\'')}'" if isinstance(val, str) or isinstance(val, bytes) else
                                 'NULL' if val is None else 
                                 f"'{val.strftime('%Y-%m-%d')}'" if isinstance(val, datetime.date) else
                                 f"'{val}'" if isinstance(val, datetime.datetime) else
                                 str(val)
                                 for val in wiersz]
                            )
                            plik.write(f"INSERT INTO {tabela} ({', '.join(kolumny)}) VALUES ({wartosci});\n")  # Zapisz instrukcję INSERT
                        plik.write("\n")  # Dodaj nową linię między tabelami
                    else:
                        logger.warning(f"Tabela {tabela} jest pusta. Brak danych do zapisania.")

            logger.info(f"Dane zapisano do pliku: {nazwa_pliku}")

    except Exception as e:
        logger.error(f"Wystąpił błąd podczas zapisu do pliku: {e}")
# Uruchom wątek do zapisu danych
zapisywanie_thread = threading.Thread(target=zapisz_wszystkie_dane_do_plikow)
zapisywanie_thread.start()
@app.before_request
def load_logged_in_user():
    user_id = request.cookies.get('user_id')
    if user_id:
        g.user = Uzytkownik.query.get(int(user_id))
        
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
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    if request.method == 'POST':
        # Odbierz dane z formularza
        login = request.form.get('login')
        haslo = request.form.get('password')
        
        
        uprawnienia = request.form.get('id_uprawnienia')
        # Debugowanie: sprawdź, co zostało odebrane
        
        

        # Walidacja danych
        if not login or not haslo :
            logger.warning("Wszystkie pola są wymagane.")
            return render_template('register.html', error="Wszystkie pola są wymagane.")

        # Sprawdzenie unikalności e-maila
        if Uzytkownik.query.filter_by(login=login).first():
            logger.warning("Użytkownik z tym loginem już istnieje.")
            return render_template('register.html', error="Użytkownik z tym loginem już istnieje.")

        # Dodanie danych do bazy danych
        nowy_uzytkownik = Uzytkownik(login=login, haslo=generate_password_hash(haslo),  id_uprawnienia=uprawnienia)
        db.session.add(nowy_uzytkownik)

        try:
            db.session.commit()
            logger.info("Dane zostały pomyślnie zapisane w bazie danych.")
            return redirect(url_for('uzytkownik'))  # Przekierowanie na stronę główną
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('register.html', error="Wystąpił błąd przy zapisywaniu danych.")
@app.route('/get-uprawnienia', methods=['GET'])
def get_uprawnienia():
    uprawnienia = Uprawnienia.query.all()
    return jsonify([{"id": u.id_uprawnienia, "nazwa": u.nazwa} for u in uprawnienia])
@app.route('/get-szanlon', methods=['GET'])
def get_szablon():
    szablon = Szablon.query.all()
    return jsonify([{"id": s.id, "nazwa": s.nazwa} for s in szablon])
@app.route('/get-dostawcy', methods=['GET'])
def get_dostawcy(): 
    dostawcy = Dostawcy.query.all()
    return jsonify([{"id": d.id, "nazwa": d.nazwa} for d in dostawcy])
@app.route('/get-uzytkownicy')
def get_uzytkownicy():
    users = User.query.with_entities(User.login).all()  # Pobiera loginy użytkowników
    return jsonify([{"login": user.login} for user in users])
@app.route('/update-row_uzytkownik', methods=['POST'])
def update_user():
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    
    data = request.json
    user_id = data.get("column_0")
    login = data.get("column_1")
    haslo = data.get("column_2")
    if not haslo:  # Jeśli puste, nie zmieniamy hasła
        haslo = None
    id_uprawnienia = data.get("column_3")  # Teraz dostajemy ID uprawnienia

    user = Uzytkownik.query.get(user_id)
    if not user:
        return jsonify({"error": "Użytkownik nie istnieje"}), 404

    # 🛠 WALIDACJA: Sprawdź, czy uprawnienie istnieje w bazie
    if id_uprawnienia:
        uprawnienie = Uprawnienia.query.get(id_uprawnienia)
        if not uprawnienie:
            return jsonify({"error": "Nieprawidłowe uprawnienie!"}), 400
        user.id_uprawnienia = id_uprawnienia  # Bezpośrednio przypisujemy ID

    user.login = login

    if haslo:  # Tylko jeśli hasło zostało podane
        user.haslo = generate_password_hash(haslo)

    db.session.commit()
    return jsonify({"success": "Dane zaktualizowane pomyślnie!"})
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        login = request.form.get('login')
        password = request.form.get('password')

        user = Uzytkownik.query.filter_by(login=login).first()
        logger.info(f"Próba logowania dla logina: {login}")

        response = None

        if user and check_password_hash(user.haslo, password):
            response = make_response(redirect(url_for('home')))
            remember_me = request.form.get('remember_me')  # Sprawdzenie, czy zaznaczone "zapamiętaj mnie"
            if remember_me:  # Jeśli zaznaczone, ustaw cookie na 30 dni
                max_age = timedelta(days=30)
            else:  # Jeśli nie, cookie wygasa po zamknięciu przeglądarki
                max_age = None
            
            response.set_cookie('user_id', str(user.id), httponly=True, secure=False, samesite='Strict', max_age=max_age)
            logger.info(f"Użytkownik {user.login} zalogowany pomyślnie.")
            return response
        else:
            logger.warning("Nieudana próba logowania.")
            return render_template('login.html', error="Błędny login lub hasło")

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
    login = request.form['login']
    comments = request.form['comments']

    # Dane serwera SMTP
    smtp_server = 'poczta.interia.pl'
    smtp_port = 465  # Dla SSL
    sender_login = 'kontakt_lumpstore@interia.pl'
    sender_password = 'LumpStore1@3'

    # Utwórz wiadomość e-mail
    msg = loginMessage()
    msg['Subject'] = 'Pomoc techniczna LumpStore'
    msg['From'] = sender_login
    msg['To'] = sender_login  # Możesz zmienić na adres obsługi klienta
    msg.set_content(f"E-mail od: {login}\n\nTreść wiadomości:\n{comments}")

    try:
        # Połączenie z serwerem SMTP z SSL
        context = ssl.create_default_context()
        with smtplib.SMTP_SSL(smtp_server, smtp_port, context=context) as smtp:
            smtp.login(sender_login, sender_password)
            smtp.send_message(msg)
        return redirect(url_for('home', success="Wiadomość została wysłana pomyślnie.",user=g.user ))
    except Exception as e:
        error_message = traceback.format_exc()
        print(f"Błąd podczas wysyłania wiadomości: {error_message}")
        return redirect(url_for('home', error="Nie udało się wysłać wiadomości. Skontaktuj się później.",user=g.user))

@app.route('/uzytkownik')
def uzytkownik():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    return render_template("uzytkownik.html", user=g.user, uzytkownicy=Uzytkownik.query.all(),uprawnienia=Uprawnienia.query.all())   




@app.route('/register')
def register():
     if not g.user:
        return render_template('login.html', user=g.user)
     if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
     return render_template("register.html")

@app.route('/regulamin')
def regulamin():
    return render_template("regulamin.html")

@app.route('/tasma')
def tasma():
    
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))

    # Jeśli użytkownik ma uprawnienia 1, pobierz wszystkie wpisy
    if g.user.uprawnienia.id_uprawnienia == 1:
        tasma = Tasma.query.all()
    else:
        # W przeciwnym razie pobierz tylko te wpisy, które stworzył zalogowany użytkownik
        tasma = Tasma.query.filter_by(pracownik_id=g.user.id).all()
    
    return render_template("tasma.html", user=g.user, tasma=tasma,uprawnienia=Uprawnienia.query.all(),szablon=Szablon.query.all(),dostawcy=Dostawcy.query.all())
@app.route('/update-row', methods=['POST'])
def update_row():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    try:
        dane = request.get_json()
        logging.info(f'Otrzymane dane: {dane}')

        # Użyj column_0 jako id
        id = dane.get('column_0')  # Zmiana tutaj
        if id is None:
            return jsonify({'message': 'Id jest wymagane!'}), 400  # Błąd, gdy id jest None

        tasma = Tasma.query.get(id)
        if tasma is None:
            return jsonify({'message': 'Rekord nie znaleziony!'}), 404  # Błąd, gdy rekord nie istnieje

        # Aktualizacja danych
        tasma.dostawca_id = dane.get('column_1', tasma.nazwa_dostawcy)
        tasma.szablon_id = dane.get('column_2', tasma.nazwa_materialu)
        tasma.data_z_etykiety_na_kregu = dane.get('column_3', tasma.data_z_etykiety_na_kregu)
        tasma.grubosc = dane.get('column_4', tasma.grubosc)
        tasma.szerokosc = dane.get('column_5', tasma.szerokosc)
        tasma.waga_kregu = dane.get('column_6', tasma.waga_kregu)
        tasma.nr_etykieta_paletowa = dane.get('column_7', tasma.nr_etykieta_paletowa)
        tasma.nr_z_etykiety_na_kregu = dane.get('column_8', tasma.nr_z_etykiety_na_kregu)
        tasma.lokalizacja = dane.get('column_9', tasma.lokalizacja)
        tasma.nr_faktury_dostawcy = dane.get('column_10', tasma.nr_faktury_dostawcy)
        tasma.data_dostawy = dane.get('column_11', tasma.data_dostawy)

        db.session.commit()
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'})
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': 'Wystąpił błąd podczas aktualizacji!', 'error': str(e)}), 500
@app.route('/dodaj_tasma')
def dodaj_tasma():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    return render_template("dodaj_tasma.html", user=g.user,dostawcy=Dostawcy.query.all(),nazwy_materiału=Szablon.query.all())
@app.route('/dodaj_tasma_do_bazy', methods=['POST'])
def dodaj_tasma_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    if request.method == 'POST':
        # Odbierz dane z formularza
        
        dostawca_id = request.form.get('dostawcy')
        szablon_id = int(request.form.get('nazwa_materiału'))
        data_z_etykiety_na_kregu = request.form.get('data_z_etykiety_na_kregu')
        grubosc = Szablon.query.get(szablon_id).grubosc 
        szerokosc = Szablon.query.get(szablon_id).szerokosc 
        waga_kregu = request.form.get('waga_kregu')
        nr_etykieta_paletowa = request.form.get('nr_etykieta_paletowa')
        nr_z_etykiety_na_kregu = request.form.get('nr_z_etykiety_na_kregu')
        lokalizacja = request.form.get('lokalizacja')
        nr_faktury_dostawcy = request.form.get('nr_faktury_dostawcy')
        data_dostawy = request.form.get('data_dostawy')
        pracownik_id = g.user.id

        

        # Dodanie danych do bazy danych
        nowy_uzytkownik = Tasma(dostawca_id=dostawca_id, szablon_id=szablon_id, data_z_etykiety_na_kregu=data_z_etykiety_na_kregu, grubosc=grubosc, szerokosc=szerokosc, waga_kregu=waga_kregu, nr_etykieta_paletowa=nr_etykieta_paletowa, nr_z_etykiety_na_kregu=nr_z_etykiety_na_kregu, lokalizacja=lokalizacja, nr_faktury_dostawcy=nr_faktury_dostawcy, data_dostawy=data_dostawy, pracownik_id=pracownik_id)
        db.session.add(nowy_uzytkownik)

        try:
            db.session.commit()
            logger.info("Dane zostały pomyślnie zapisane w bazie danych.")
            # Nie zwracamy żadnej odpowiedzi, jeśli nie wystąpił błąd.
            return "", 204  # Użycie kodu statusu 204 (No Content)
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return jsonify({'message': 'Błąd{e}!'})

@app.route('/profil')
def profil():
    
    if not g.user:
        return render_template('login.html', user=g.user)
    #if g.user.uprawnienia.id_uprawnienia == 1 or g.user.uprawnienia.id_uprawnienia == 2:
    profil = Profil.query.all()
    
   # else:
        # W przeciwnym razie pobierz tylko te wpisy, które stworzył zalogowany użytkownik
        #profil = Profil.query.filter_by(pracownik_id=g.user.id).all()
    return render_template("profil.html", user=g.user,profil=profil,uprawnienia=Uprawnienia.query.all(),currentDate = date.today().strftime('%Y-%m-%d'),currentDate1=(date.today() - timedelta(days=1)).strftime('%Y-%m-%d'),currentDate2=(date.today() - timedelta(days=2)).strftime('%Y-%m-%d'))
@app.route('/update-row_profil', methods=['POST'])
def update_row_profil():
    if not g.user:
        return render_template('login.html', user=g.user)
    try:
        dane = request.get_json()
        logging.info(f'Otrzymane dane: {dane}')

        # Użyj column_0 jako id
        id = dane.get('column_0')  # Zmiana tutaj
        if id is None:
            return jsonify({'message': 'Id jest wymagane!'}), 400  # Błąd, gdy id jest None

        profil = Profil.query.get(id)
        if profil is None:
            return jsonify({'message': 'Rekord nie znaleziony!'}), 404  # Błąd, gdy rekord nie istnieje

        # Aktualizacja danych
        try:
            profil.id_tasmy = dane.get('column_1', profil.id_tasmy)
        except:
            pass
        try:
            profil.data_produkcji = dane.get('column_2', profil.data_produkcji)
        except:
            pass
        try:
            profil.godz_min_rozpoczecia = dane.get('column_3', profil.godz_min_rozpoczecia)
        except:
            pass
        try:
            profil.godz_min_zakonczenia = dane.get('column_4', profil.godz_min_zakonczenia)
        except:
            pass
        try:
            profil.zwrot_na_magazyn_kg = dane.get('column_5', profil.zwrot_na_magazyn_kg)
        except:
            pass
        try:
            profil.nr_czesci_klienta = dane.get('column_6', profil.nr_czesci_klienta)
        except:
            pass
        try:
            profil.nazwa_klienta_nr_zlecenia_PRODIO = dane.get('column_7', profil.nazwa_klienta_nr_zlecenia_PRODIO)
        except:
            pass
        try:
            profil.id_pracownika = dane.get('column_8', profil.id_pracownika)
        except:
            pass
        
        

        db.session.commit()
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'})
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': 'Wystąpił błąd podczas aktualizacji!', 'error': str(e)}), 500
@app.route('/dodaj_profil')
def dodaj_profil():
    if not g.user:
        return render_template('login.html', user=g.user)
    tasmy = Tasma.query.all()
    return render_template("dodaj_profil.html", user=g.user,tasmy=tasmy)
@app.route('/dodaj_profil_do_bazy', methods=['POST'])
def dodaj_profil_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    
    if request.method == 'POST':
        # Odbierz dane z formularza
        id_tasmy = request.form.get('etykieta')  
        data_produkcji = request.form.get('data_produkcji')
        godz_min_rozpoczecia = request.form.get('godz_min_rozpoczecia')
        godz_min_zakonczenia = request.form.get('godz_min_zakonczenia')
        zwrot_na_magazyn_kg = request.form.get('zwrot_na_magazyn_kg')
        nr_czesci_klienta = request.form.get('nr_czesci_klienta')
        nazwa_klienta_nr_zlecenia_PRODIO = request.form.get('nazwa_klienta_nr_zlecenia_PRODIO')
        
        pracownik_id = g.user.id  # ID pracownika z sesji

        # Dodanie danych do bazy danych
        nowy_profil = Profil(
            id_tasmy=id_tasmy,
            data_produkcji=data_produkcji,
            godz_min_rozpoczecia=godz_min_rozpoczecia,
            godz_min_zakonczenia=godz_min_zakonczenia,
            zwrot_na_magazyn_kg=zwrot_na_magazyn_kg,
            nr_czesci_klienta=nr_czesci_klienta,
            nazwa_klienta_nr_zlecenia_PRODIO=nazwa_klienta_nr_zlecenia_PRODIO,
            
            id_pracownika=pracownik_id
        )
        tasma = Tasma.query.get(id_tasmy)
        if tasma:
            tasma.waga_kregu = zwrot_na_magazyn_kg
        db.session.add(nowy_profil)

    try:
        db.session.commit()
        logger.info("Dane zostały pomyślnie zapisane w bazie danych.")
        return redirect(url_for('profil'))  # Przekierowanie na stronę główną
    except Exception as e:
        db.session.rollback()
        logger.error(f"Nie udało się zapisać danych: {e}")
        return render_template('profil.html', error="Wystąpił błąd przy zapisywaniu danych.", user=g.user)
@app.route('/dostawcy')
def dostawcy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    dostawcy = Dostawcy.query.all()
    return render_template("dostawcy.html", user=g.user, dostawcy=dostawcy)
@app.route('/dodaj_dostawce')
def dodaj_dostawce():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    return render_template("dodaj_dostawce.html", user=g.user)
@app.route('/dodaj_dostawce_do_bazy', methods=['POST'])
def dodaj_dostawce_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    if request.method == 'POST':
        # Odbierz dane z formularza
        nazwa = request.form.get('nazwa_dostawcy')

        # Dodanie danych do bazy danych
        nowy_dostawca = Dostawcy(nazwa=nazwa)
        db.session.add(nowy_dostawca)

        try:
            db.session.commit()
            logger.info("Dane zostały pomyślnie zapisane w bazie danych.")
            return redirect(url_for('dostawcy'))  # Przekierowanie na stronę główną
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('dostawcy.html', error="Wystąpił błąd przy zapisywaniu danych.", user=g.user)
    return render_template("dostawcy.html", user=g.user)
@app.route('/update-row-dostawcy', methods=['POST'])
def update_row_dostawcy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    try:
        dane = request.get_json()
        logging.info(f'Otrzymane dane: {dane}')

        # Użyj column_0 jako id
        id = dane.get('column_0')  # Zmiana tutaj
        if id is None:
            return jsonify({'message': 'Id jest wymagane!'}), 400  # Błąd, gdy id jest None

        dostawca = Dostawcy.query.get(id)
        if dostawca is None:
            return jsonify({'message': 'Rekord nie znaleziony!'}), 404  # Błąd, gdy rekord nie istnieje

        # Aktualizacja danych
        dostawca.nazwa = dane.get('column_1', dostawca.nazwa)
        

        db.session.commit()
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'})
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': 'Wystąpił błąd podczas aktualizacji!', 'error': str(e)}), 500
@app.route('/szablon')
def szablon():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    szablon = Szablon.query.all()
    return render_template("szablon.html", user=g.user, szablony=szablon)
@app.route('/dodaj_szablon')
def dodaj_szablon():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    return render_template("dodaj_szablon.html", user=g.user)
@app.route('/dodaj_szablon_do_bazy', methods=['POST'])
def dodaj_szablon_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    if request.method == 'POST':
        rodzaj = request.form.get('rodzaj_tasmy')
        grubosc_i_oznaczenie_ocynku = request.form.get('grubosc_i_oznaczenie_ocynku')
        grubosc = request.form.get('grubosc')
        szerokosc = request.form.get('szerokosc')
        nazwa=rodzaj + " " + grubosc_i_oznaczenie_ocynku + " " + szerokosc + "x" +  grubosc
        # Dodanie danych do bazy danych
        nowy_szablon = Szablon(nazwa=nazwa, rodzaj=rodzaj, grubosc_i_oznaczenie_ocynku=grubosc_i_oznaczenie_ocynku, grubosc=grubosc, szerokosc=szerokosc)
        db.session.add(nowy_szablon)
        try:
            db.session.commit()
            logger.info("Dane zostały pomyślnie zapisane w bazie danych.")
            return redirect(url_for('szablon'))  # Przekierowanie na stronę główną
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('szablon.html', error="Wystąpił błąd przy zapisywaniu danych.", user=g.user)
@app.route('/update-row-szablon', methods=['POST'])
def update_row_szablon():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    try:
        dane = request.get_json()
        logging.info(f'Otrzymane dane: {dane}')

        # Użyj column_0 jako id
        id = dane.get('column_0')  # Zmiana tutaj
        if id is None:
            return jsonify({'message': 'Id jest wymagane!'}), 400  # Błąd, gdy id jest None

        szablon = Szablon.query.get(id)
        if szablon is None:
            return jsonify({'message': 'Rekord nie znaleziony!'}), 404  # Błąd, gdy rekord nie istnieje

        # Aktualizacja danych
        szablon.nazwa = dane.get('column_1', szablon.nazwa)
        szablon.rodzaj = dane.get('column_2', szablon.rodzaj)
        szablon.grubosc_i_oznaczenie_ocynku = dane.get('column_3', szablon.grubosc_i_oznaczenie_ocynku)
        szablon.grubosc = dane.get('column_4', szablon.grubosc)
        szablon.szerokosc = dane.get('column_5', szablon.szerokosc)
        

        db.session.commit()
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'})
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': 'Wystąpił błąd podczas aktualizacji!', 'error': str(e)}), 500


if __name__ == "__main__":
    app.run (host='0.0.0.0',port=5000,debug=True)