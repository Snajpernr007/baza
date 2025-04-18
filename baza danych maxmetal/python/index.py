from flask import Flask, render_template, request, redirect, url_for, g, make_response, flash, jsonify,  send_file
from flask_sqlalchemy import SQLAlchemy
import logging
from sqlalchemy import text
import base64
import smtplib
from email.message import EmailMessage
from datetime import timedelta, date
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import ssl
import os
import datetime
from sqlalchemy.exc import SQLAlchemyError
from flask_wtf import FlaskForm
from wtforms import StringField, DecimalField, TextAreaField, SelectField, FileField, IntegerField, SubmitField
from wtforms.validators import DataRequired, Length
import threading
import time
from decimal import Decimal
import pandas as pd
import io  # Dodaj ten import
import openpyxl
from io import BytesIO
# Utwórz katalog logs, jeśli nie istnieje
if not os.path.exists('logs'):
    os.makedirs('logs')

# Konfiguracja logowania
logging.basicConfig(
    filename='logs/app.log',  # Lokalizacja pliku logu
    level=logging.INFO,  # Poziom logowania
    format='%(asctime)s - %(levelname)s - %(message)s',  # Format komunikatu logu
    encoding='utf-8'  # Umożliwienie zapisu polskich znaków
)

logger = logging.getLogger(__name__)

app = Flask(__name__, template_folder="../templates/", static_folder="../static")
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost/baza_max'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # Maksymalny rozmiar pliku: 16MB
app.config['UPLOAD_EXTENSIONS'] = ['.jpg', '.png', '.gif']
app.secret_key = 'supersecretkey'
app.config['UPLOAD_FOLDER'] = '/../static/img'
db = SQLAlchemy(app)

try:
    with app.app_context():
        connection = db.engine.connect()  # Uzyskaj połączenie
        connection.execute(text("SELECT 1"))  # Prosta kwerenda, aby sprawdzić połączenie
        logger.info("Połączenie z bazą danych zostało nawiązane pomyślnie.")
        connection.close()  # Zamknij połączenie
except Exception as e:
    logger.error(f"Nie udało się połączyć z bazą danych: {e}")

# Modele bazy danych

class Lokalizacja(db.Model):
    __tablename__ = 'lokalizacja'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    nazwa = db.Column(db.String(255), nullable=False)

    def __repr__(self):
        return f"<Lokalizacja {self.id} - {self.nazwa}>"
class Dlugosci(db.Model):
    __tablename__ = 'dlugosci'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    nazwa = db.Column(db.String(255), nullable=False)
    profil = db.relationship('Profil', back_populates='dlugosci')
    def __repr__(self):
        return f"<Dlugosci {self.id} - {self.nazwa}>"
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
    waga_kregu_na_stanie = db.Column(db.Numeric(10, 2), nullable=True)
    nr_etykieta_paletowa = db.Column(db.String(255), nullable=False)
    nr_z_etykiety_na_kregu = db.Column(db.String(255), nullable=False)
    lokalizacja_id = db.Column(db.Integer, db.ForeignKey('lokalizacja.id'), nullable=False)

    lokalizacja = db.relationship('Lokalizacja', backref='tasmy')
    nr_faktury_dostawcy = db.Column(db.String(255), nullable=False)
    data_dostawy = db.Column(db.Date, nullable=False)
    pracownik_id = db.Column(db.Integer, db.ForeignKey('uzytkownicy.id'), nullable=True)
    dostawca_id = db.Column(db.Integer, db.ForeignKey('dostawcy.id'), nullable=False)
    szablon_id = db.Column(db.Integer, db.ForeignKey('szablon.id'), nullable=False)
    Data_do_usuwania = db.Column(db.Date, nullable=True)
    
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
    ilosc=db.Column(db.Integer, nullable=False)
    id_dlugosci = db.Column(db.Integer, db.ForeignKey('dlugosci.id'), nullable=False)
    Data_do_usuwania = db.Column(db.Date, nullable=True)
    id_pracownika = db.Column(db.Integer, db.ForeignKey('uzytkownicy.id'), nullable=False)

    tasma = db.relationship('Tasma', back_populates='profil')
    pracownik = db.relationship('Uzytkownik', back_populates='profil')
    dlugosci = db.relationship('Dlugosci', back_populates='profil')
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

# Backup Directory
BACKUP_DIR = "backups"
INTERVAL_HOURS = 4
os.makedirs(BACKUP_DIR, exist_ok=True)

def format_sql_value(val):
    if val is None:
        return "NULL"
    return "'" + str(val).replace("'", "''") + "'"
def zapisz_do_pliku_sql():
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M')
    nazwa_pliku = os.path.join(BACKUP_DIR, f'kopie_zapasowe_bazy_{timestamp}.sql')

    try:
        with app.app_context():
            with open(nazwa_pliku, 'w', encoding='utf-8') as plik:
                plik.write("SET FOREIGN_KEY_CHECKS = 0;\n\n")

                kolejnosc_tabel = [
                    'uprawnienia',
                    'uzytkownicy',
                    'dostawcy',
                    'szablon',
                    'lokalizacja',
                    'dlugosci',
                    'tasma',
                    'profil'
                ]

                for tabela in kolejnosc_tabel:
                    create_result = db.session.execute(text(f"SHOW CREATE TABLE `{tabela}`")).fetchone()
                    create_stmt = create_result[1]
                    plik.write(f"-- Struktura tabeli `{tabela}`\n{create_stmt};\n\n")

                for tabela in kolejnosc_tabel:
                    query = text(f"SELECT * FROM `{tabela}`;")
                    result = db.session.execute(query)
                    rows = result.fetchall()
                    columns = result.keys()

                    if not rows:
                        logger.info(f"Tabela {tabela} jest pusta.")
                        continue

                    plik.write(f"-- Dane z tabeli `{tabela}`\n")
                    for row in rows:
                        formatted_values = [format_sql_value(val) for val in row]
                        values = ', '.join(formatted_values)
                        insert_statement = f"INSERT INTO `{tabela}` ({', '.join(columns)}) VALUES ({values});"
                        plik.write(insert_statement + "\n")
                        
                    plik.write("\n")

                plik.write("\nSET FOREIGN_KEY_CHECKS = 1;\n")

            logger.info(f"✅ Kopia zapasowa zapisana do pliku: {nazwa_pliku}")

            backup_files = sorted(
                [f for f in os.listdir(BACKUP_DIR) if f.endswith(".sql")],
                key=lambda x: os.path.getctime(os.path.join(BACKUP_DIR, x))
            )
            while len(backup_files) > 6:
                najstarszy = backup_files.pop(0)
                os.remove(os.path.join(BACKUP_DIR, najstarszy))
                logger.info(f"🗑️ Usunięto starą kopię: {najstarszy}")

    except Exception as e:
        logger.error(f"❌ Błąd podczas tworzenia kopii zapasowej: {e}")

def zapisz_wszystkie_dane_do_plikow():
    try:
        while True:
            zapisz_do_pliku_sql()
            time.sleep(INTERVAL_HOURS * 3600)
    except Exception as e:
        logger.error(f"Błąd w pętli backupu: {e}")

# Uruchomienie wątku
backup_thread = threading.Thread(target=zapisz_wszystkie_dane_do_plikow, daemon=True)
backup_thread.start()

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
        logger.info("Nieautoryzowany dostęp do strony głównej.")
        return render_template('login.html', user=g.user)
    
    logger.info(f"{g.user.login} wszedł na stronę główną.")
    resp = make_response(render_template('index.html', user=g.user))
    resp.set_cookie('last', request.path)  # Zapisz ostatni URL

    return resp

@app.route('/go_back')
def go_back():
    last_url = request.cookies.get('last')  # Pobierz ostatni URL z ciasteczka
    if last_url:
        response = make_response(redirect(last_url))  # Przekieruj do ostatniego URL
        response.delete_cookie('last')  # Możesz usunąć ciasteczko po przekierowaniu, jeśli nie jest już potrzebne
        logger.info(f"{g.user.login} wrócił do {last_url}.")
        return response
    logger.warning(f"Brak historii do powrotu dla {g.user.login}.")
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

        # Walidacja danych
        if not login or not haslo:
            logger.warning("Wszystkie pola są wymagane.")
            return render_template('register.html', error="Wszystkie pola są wymagane.")

        if Uzytkownik.query.filter_by(login=login).first():
            logger.warning("Użytkownik z tym loginem już istnieje.")
            return render_template('register.html', error="Użytkownik z tym loginem już istnieje.")

        nowy_uzytkownik = Uzytkownik(login=login, haslo=generate_password_hash(haslo), id_uprawnienia=uprawnienia)
        db.session.add(nowy_uzytkownik)

        try:
            db.session.commit()
            logger.info(f"Dane użytkownika {login} zostały pomyślnie zapisane w bazie danych.")
            return redirect(url_for('uzytkownik'))  # Przekierowanie na stronę główną
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('register.html', error="Wystąpił błąd przy zapisywaniu danych.")

@app.route('/get-uprawnienia', methods=['GET'])
def get_uprawnienia():
    uprawnienia = Uprawnienia.query.all()
    return jsonify([{"id": u.id_uprawnienia, "nazwa": u.nazwa} for u in uprawnienia])

@app.route('/get-szablon', methods=['GET'])
def get_szablon():
    szablon = Szablon.query.all()
    return jsonify([{"id": s.id, "nazwa": s.nazwa} for s in szablon])

@app.route('/get-dostawcy', methods=['GET'])
def get_dostawcy(): 
    dostawcy = Dostawcy.query.all()
    return jsonify([{"id": d.id, "nazwa": d.nazwa} for d in dostawcy])

@app.route('/get-uzytkownicy')
def get_uzytkownicy():
    users = Uzytkownik.query.with_entities(Uzytkownik.login).all()  # Pobiera loginy użytkowników
    return jsonify([{"login": user.login} for user in users])

@app.route('/get-tasma', methods=['GET'])
def get_tasma():
    tasma = Tasma.query.all()
    return jsonify([{"id": t.id, "nr_z_etykiety_na_kregu": t.nr_z_etykiety_na_kregu} for t in tasma])
@app.route('/get-lokalizacja', methods=['GET'])
def get_lokalizacja():
    lokalizacja = Lokalizacja.query.all()
    return jsonify([{"id": l.id, "nazwa": l.nazwa} for l in lokalizacja])
@app.route('/get-dlugosci', methods=['GET'])
def get_dlugosci():
    dlugosci = Dlugosci.query.all()
    return jsonify([{"id": d.id, "nazwa": d.nazwa} for d in dlugosci])
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
        logger.warning(f"Użytkownik o ID {user_id} nie istnieje.")
        return jsonify({"error": "Użytkownik nie istnieje"}), 404

    # Walidacja uprawnienia
    if id_uprawnienia:
        uprawnienie = Uprawnienia.query.get(id_uprawnienia)
        if not uprawnienie:
            logger.warning(f"Nieprawidłowe uprawnienie ID: {id_uprawnienia}.")
            return jsonify({"error": "Nieprawidłowe uprawnienie!"}), 400
        user.id_uprawnienia = id_uprawnienia  # Bezpośrednio przypisujemy ID

    user.login = login

    if haslo:  # Tylko jeśli hasło zostało podane
        user.haslo = generate_password_hash(haslo)

    db.session.commit()
    logger.info(f"Zaktualizowano dane użytkownika {user.login}.")
    return jsonify({"success": "Dane zaktualizowane pomyślnie!"})

@app.route('/usun_uzytkownik/<int:id>', methods=['POST'])
def usun_uzytkownik(id):
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    uzytkownik = Uzytkownik.query.get_or_404(id)

    try:
        db.session.delete(uzytkownik)
        db.session.commit()
        logger.info(f"Użytkownik {uzytkownik.login} został usunięty.")
        flash('Użytkownik został usunięty.', 'success')
    except Exception as e:
        db.session.rollback()
        logger.error(f'Błąd przy usuwaniu użytkownika: {e}')
        flash(f'Błąd przy usuwaniu: {e}', 'danger')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        login = request.form.get('login')
        password = request.form.get('password')

        user = Uzytkownik.query.filter_by(login=login).first()
        logger.info(f"Próba logowania dla logina: {login}")

        response = None

        if user and check_password_hash(user.haslo, password):
            g.user = user
            response = make_response(redirect(url_for('home')))
            remember_me = request.form.get('remember_me')  # Sprawdzenie, czy zaznaczone "zapamiętaj mnie"
            max_age = timedelta(days=30) if remember_me else None
            response.set_cookie('user_id', str(user.id), httponly=True, secure=False, samesite='Strict', max_age=max_age)
            logger.info(f"Użytkownik {user.login} zalogowany pomyślnie.")
            return response
        else:
            logger.warning("Nieudana próba logowania.")
            return render_template('login.html', error="Błędny login lub hasło")

    return render_template('login.html')

@app.route('/logout')
def logout():
    if g.user:
        logger.info(f"Użytkownik {g.user.login} wylogowany.")
    response = make_response(redirect(url_for('home')))
    response.set_cookie('user_id', '', expires=0, httponly=True, secure=False, samesite='Strict')
    return response

@app.route('/send', methods=['POST'])
def send():
    # Pobierz dane z formularza
    message = request.form.get('message')
    nowa_cecha = Cechy(nazwa=message)
    db.session.add(nowa_cecha)
    db.session.commit()

    logger.info(f"Wysłano do bazy: {message}")  # Zapis do logów
    return render_template("index.html")

@app.route('/contact')
def contact():
    logger.info(f"{g.user.login} wszedł na stronę kontaktową.")
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
    msg = EmailMessage()
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
        logger.info(f"Wiadomość od {login} została wysłana pomyślnie.")
        return redirect(url_for('home', success="Wiadomość została wysłana pomyślnie.", user=g.user))
    except Exception as e:
        logger.error(f"Błąd podczas wysyłania wiadomości: {e}")
        return redirect(url_for('home', error="Nie udało się wysłać wiadomości. Skontaktuj się później.", user=g.user))

@app.route('/uzytkownik')
def uzytkownik():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    
    logger.info(f"{g.user.login} wszedł na stronę zarządzania użytkownikami.")
    return render_template("uzytkownik.html", user=g.user, uzytkownicy=Uzytkownik.query.all(), uprawnienia=Uprawnienia.query.all())

@app.route('/register')
def register():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    
    logger.info(f"{g.user.login} wszedł na stronę rejestracji użytkownika.")
    return render_template("register.html")

@app.route('/usun_tasma/<int:id>', methods=['POST'])
def usun_tasma(id):
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    
    tasma = Tasma.query.get_or_404(id)
    
    try:
        db.session.delete(tasma)
        db.session.commit()
        logger.info(f"Tasma {tasma.nr_z_etykiety_na_kregu} została usunięta.")
        flash('Tasma została usunięta.', 'success')
    except Exception as e:
        db.session.rollback()
        logger.error(f'Błąd przy usuwaniu tasy: {e}')
        flash(f'Błąd przy usuwaniu: {e}', 'danger')
    
    return redirect(request.referrer or url_for('home'))

@app.route('/tasma')
def tasma():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1 and g.user.id_uprawnienia != 2:
        return redirect(url_for('home'))

    if g.user.uprawnienia.id_uprawnienia == 1 or g.user.uprawnienia.id_uprawnienia == 2:
        tasma = Tasma.query.all()
    else:
        tasma = Tasma.query.filter_by(pracownik_id=g.user.id).all()
    
    logger.info(f"{g.user.login} wszedł na stronę z listą tasm.")
    return render_template("tasma.html", user=g.user, tasma=tasma, uprawnienia=Uprawnienia.query.all(), szablon=Szablon.query.all(), dostawcy=Dostawcy.query.all(),lokalizacja=Lokalizacja.query.all(), currentDate3=date.today())

@app.route('/update-row', methods=['POST'])
def update_row():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1 and g.user.id_uprawnienia != 2:
        return redirect(url_for('home'))

    try:
        dane = request.get_json()
        logger.info(f"Otrzymane dane do aktualizacji tasy: {dane}")

        id = dane.get('column_0')  # Id rekordu do aktualizacji
        if id is None:
            return jsonify({'message': 'Id jest wymagane!'}), 400

        tasma = db.session.get(Tasma, id)
        if tasma is None:
            return jsonify({'message': 'Rekord nie znaleziony!'}), 404

        # Aktualizacja danych
        tasma.dostawca_id = dane.get('column_1', tasma.dostawca_id)
        tasma.szablon_id = dane.get('column_2', tasma.szablon_id)
        tasma.data_z_etykiety_na_kregu = dane.get('column_3', tasma.data_z_etykiety_na_kregu)

        tasma.grubosc = Szablon.query.get(tasma.szablon_id).grubosc
        tasma.szerokosc = Szablon.query.get(tasma.szablon_id).szerokosc
        tasma.waga_kregu = dane.get('column_6', tasma.waga_kregu)
        tasma.waga_kregu_na_stanie = dane.get('column_7', tasma.waga_kregu_na_stanie)
        tasma.nr_etykieta_paletowa = dane.get('column_8', tasma.nr_etykieta_paletowa)
        tasma.nr_z_etykiety_na_kregu = dane.get('column_9', tasma.nr_z_etykiety_na_kregu)
        tasma.lokalizacja = dane.get('column_10', tasma.lokalizacja)
        tasma.nr_faktury_dostawcy = dane.get('column_11', tasma.nr_faktury_dostawcy)
        tasma.data_dostawy = dane.get('column_12', tasma.data_dostawy)

        db.session.commit()  # Zapisz zmiany w bazie
        logger.info(f"Tasma o ID {id} została zaktualizowana przez {g.user.login}.")
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'})
    except Exception as e:
        db.session.rollback()  # Wycofanie zmian w przypadku błędu
        logger.error(f'Wystąpił błąd podczas aktualizacji tasy: {e}')
        return jsonify({'message': 'Wystąpił błąd podczas aktualizacji!', 'error': str(e)}), 500

@app.route('/dodaj_tasma')
def dodaj_tasma():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1 and g.user.id_uprawnienia != 2:
        return redirect(url_for('home'))
    
    logger.info(f"{g.user.login} wszedł na stronę dodawania tasy.")
    return render_template("dodaj_tasma.html", user=g.user, dostawcy=Dostawcy.query.all(), nazwy_materiału=Szablon.query.all(),lokalizacje=Lokalizacja.query.all())

@app.route('/dodaj_tasma_do_bazy', methods=['POST'])
def dodaj_tasma_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1 and g.user.id_uprawnienia != 2:
        return redirect(url_for('home'))
    
    if request.method == 'POST':
        dostawca_id = request.form.get('dostawcy')
        szablon_id = int(request.form.get('nazwa_materiału'))
        data_z_etykiety_na_kregu = request.form.get('data_z_etykiety_na_kregu')
        grubosc = Szablon.query.get(szablon_id).grubosc 
        szerokosc = Szablon.query.get(szablon_id).szerokosc 
        waga_kregu = request.form.get('waga_kregu')
        waga_kregu_na_stanie = waga_kregu
        nr_etykieta_paletowa = request.form.get('nr_etykieta_paletowa')
        if nr_etykieta_paletowa == "":
            nr_etykieta_paletowa = "-"
        nr_z_etykiety_na_kregu = request.form.get('nr_z_etykiety_na_kregu')
        lokalizacja_id = int(request.form.get('lokalizacja'))
        nr_faktury_dostawcy = request.form.get('nr_faktury_dostawcy')
        data_dostawy = request.form.get('data_dostawy')
        Data_do_usuwania = date.today() + timedelta(days=365)
        pracownik_id = g.user.id

        nowy_uzytkownik = Tasma(dostawca_id=dostawca_id, szablon_id=szablon_id, 
                                 data_z_etykiety_na_kregu=data_z_etykiety_na_kregu, 
                                 grubosc=grubosc, szerokosc=szerokosc, 
                                 waga_kregu=waga_kregu, nr_etykieta_paletowa=nr_etykieta_paletowa, 
                                 nr_z_etykiety_na_kregu=nr_z_etykiety_na_kregu, 
                                 lokalizacja_id=lokalizacja_id, nr_faktury_dostawcy=nr_faktury_dostawcy, 
                                 data_dostawy=data_dostawy, pracownik_id=pracownik_id, 
                                 waga_kregu_na_stanie=waga_kregu_na_stanie, Data_do_usuwania=Data_do_usuwania)
        db.session.add(nowy_uzytkownik)

        try:
            db.session.commit()
            logger.info(f"Tasma {nr_z_etykiety_na_kregu} została dodana przez {g.user.login}.")
            return "", 204  # Użycie kodu statusu 204 (No Content)
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return jsonify({'message': f'Błąd: {e}!'})

@app.route('/profil')
def profil():
    if not g.user:
        return render_template('login.html', user=g.user)

    profil = Profil.query.all()
    logger.info(f"{g.user.login} wszedł na stronę profilu.")
    return render_template("profil.html", user=g.user, profil=profil, 
                           uprawnienia=Uprawnienia.query.all(), 
                           currentDate=date.today().strftime('%Y-%m-%d'), 
                           currentDate1=(date.today() - timedelta(days=1)).strftime('%Y-%m-%d'), 
                           currentDate2=(date.today() - timedelta(days=2)).strftime('%Y-%m-%d'), 
                           currentDate3=date.today())

@app.route('/usun_profil/<int:id>', methods=['POST'])
def usun_profil(id):
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))
    
    profil = Profil.query.get_or_404(id)
    
    try:
        db.session.delete(profil)
        db.session.commit()
        logger.info(f"Profil {profil.nr_czesci_klienta} został usunięty przez {g.user.login}.")
        flash('Profil został usunięty.', 'success')
    except Exception as e:
        db.session.rollback()
        logger.error(f'Błąd przy usuwaniu profilu: {e}')
        flash(f'Błąd przy usuwaniu: {e}', 'danger')
    
    return redirect(request.referrer or url_for('home'))

@app.route('/update-row_profil', methods=['POST'])
def update_row_profil():
    if not g.user:
        return render_template('login.html', user=g.user)

    try:
        dane = request.get_json()
        logger.info(f'Otrzymane dane do aktualizacji profilu: {dane}')

        id = dane.get('column_0')
        if id is None:
            return jsonify({'message': 'Id jest wymagane!'}), 400

        profil = Profil.query.get(id)
        if profil is None:
            logger.warning(f"Rekord nie znaleziony dla ID: {id}")
            return jsonify({'message': 'Rekord nie znaleziony!'}), 404

        # Aktualizacja pól w modelu Profil
        if 'column_1' in dane:
            profil.id_tasmy = dane['column_1']  # ID tasmy
        if 'column_2' in dane:
            profil.data_produkcji = dane['column_2']  # Data produkcji
        if 'column_3' in dane:
            profil.godz_min_rozpoczecia = dane['column_3']  # Godzina rozpoczęcia
        if 'column_4' in dane:
            profil.godz_min_zakonczenia = dane['column_4']  # Godzina zakończenia
        if 'column_5' in dane:
            profil.zwrot_na_magazyn_kg = dane['column_5']  # Zwrot na magazyn
        if 'column_6' in dane:
            profil.nr_czesci_klienta = dane['column_6']  # Nr części klienta
        if 'column_7' in dane:
            profil.nazwa_klienta_nr_zlecenia_PRODIO = dane['column_7']  # Nazwa klienta
        if 'column_8' in dane:
            profil.ilosc = dane['column_8']  # Ilość
        if 'column_9' in dane:
            profil.id_dlugosci = dane['column_9']

        logger.info(f"Aktualizacja Profil ID: {profil.id} przez {g.user.login}.")
        db.session.commit()
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'})

    except Exception as e:
        db.session.rollback()  # Wycofanie zmian w przypadku błędu
        logger.error(f'Wystąpił błąd podczas aktualizacji: {str(e)}')
        return jsonify({'message': 'Wystąpił błąd podczas aktualizacji!', 'error': str(e)}), 500

@app.route('/dodaj_profil')
def dodaj_profil():
    if not g.user:
        return render_template('login.html', user=g.user)
    
    tasmy = Tasma.query.all()
    dlugosci = Dlugosci.query.all()
    logger.info(f"{g.user.login} wszedł na stronę dodawania profilu.")
    return render_template("dodaj_profil.html", user=g.user, tasmy=tasmy,dlugosci=dlugosci)

@app.route('/dodaj_profil_do_bazy', methods=['POST'])
def dodaj_profil_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    
    if request.method == 'POST':
        id_tasmy = request.form.get('etykieta')  
        data_produkcji = request.form.get('data_produkcji')
        godz_min_rozpoczecia = request.form.get('godz_min_rozpoczecia')
        godz_min_zakonczenia = request.form.get('godz_min_zakonczenia')
        zwrot_na_magazyn_kg = request.form.get('zwrot_na_magazyn_kg')
        nr_czesci_klienta = request.form.get('nr_czesci_klienta')
        nazwa_klienta_nr_zlecenia_PRODIO = request.form.get('nazwa_klienta_nr_zlecenia_PRODIO')
        ilosc= request.form.get('ilosc')
        id_dlugosci= request.form.get('dlugosc')
        Data_do_usuwania = date.today() + timedelta(days=365)
        pracownik_id = g.user.id  # ID pracownika z sesji

        nowy_profil = Profil(
            id_tasmy=id_tasmy,
            data_produkcji=data_produkcji,
            godz_min_rozpoczecia=godz_min_rozpoczecia,
            godz_min_zakonczenia=godz_min_zakonczenia,
            zwrot_na_magazyn_kg=zwrot_na_magazyn_kg,
            nr_czesci_klienta=nr_czesci_klienta,
            nazwa_klienta_nr_zlecenia_PRODIO=nazwa_klienta_nr_zlecenia_PRODIO,
            ilosc=ilosc,
            id_dlugosci=id_dlugosci,
            Data_do_usuwania=Data_do_usuwania,
            id_pracownika=pracownik_id
        )

        db.session.add(nowy_profil)
        tasma = Tasma.query.get(id_tasmy)
        if tasma:
            tasma.waga_kregu_na_stanie = zwrot_na_magazyn_kg
        try:
            db.session.commit()
            logger.info(f"Profil dla {nr_czesci_klienta} został dodany przez {g.user.login}.")
            return redirect(url_for('profil'))  # Przekierowanie na stronę główną
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('profil.html', error="Wystąpił błąd przy zapisywaniu danych.", user=g.user)

@app.route('/dostawcy')
def dostawcy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    dostawcy = Dostawcy.query.all()
    logger.info(f"{g.user.login} wszedł na stronę dostawców.")
    return render_template("dostawcy.html", user=g.user, dostawcy=dostawcy)

@app.route('/dodaj_dostawce')
def dodaj_dostawce():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))

    logger.info(f"{g.user.login} wszedł na stronę dodawania dostawcy.")
    return render_template("dodaj_dostawce.html", user=g.user)

@app.route('/dodaj_dostawce_do_bazy', methods=['POST'])
def dodaj_dostawce_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    if request.method == 'POST':
        nazwa = request.form.get('nazwa_dostawcy')

        nowy_dostawca = Dostawcy(nazwa=nazwa)
        db.session.add(nowy_dostawca)

        try:
            db.session.commit()
            logger.info(f"Dostawca {nazwa} został dodany przez {g.user.login}.")
            return redirect(url_for('dostawcy'))  # Przekierowanie na stronę dostawców
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('dostawcy.html', error="Wystąpił błąd przy zapisywaniu danych.", user=g.user)

@app.route('/update-row-dostawcy', methods=['POST'])
def update_row_dostawcy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    try:
        dane = request.get_json()
        logger.info(f'Otrzymane dane do aktualizacji dostawcy: {dane}')

        id = dane.get('column_0')
        if id is None:
            return jsonify({'message': 'Id jest wymagane!'}), 400

        dostawca = Dostawcy.query.get(id)
        if dostawca is None:
            return jsonify({'message': 'Rekord nie znaleziony!'}), 404

        dostawca.nazwa = dane.get('column_1', dostawca.nazwa)

        db.session.commit()
        logger.info(f"Dostawca {dostawca.nazwa} został zaktualizowany przez {g.user.login}.")
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'})
    except Exception as e:
        db.session.rollback()
        logger.error(f'Wystąpił błąd podczas aktualizacji: {str(e)}')
        return jsonify({'message': 'Wystąpił błąd podczas aktualizacji!', 'error': str(e)}), 500

@app.route('/szablon')
def szablon():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    szablon = Szablon.query.all()
    logger.info(f"{g.user.login} wszedł na stronę szablonów.")
    return render_template("szablon.html", user=g.user, szablony=szablon)

@app.route('/dodaj_szablon')
def dodaj_szablon():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))

    logger.info(f"{g.user.login} wszedł na stronę dodawania szablonu.")
    return render_template("dodaj_szablon.html", user=g.user)

@app.route('/dodaj_szablon_do_bazy', methods=['POST'])
def dodaj_szablon_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    if request.method == 'POST':
        rodzaj = request.form.get('rodzaj_tasmy')
        grubosc_i_oznaczenie_ocynku = request.form.get('grubosc_i_oznaczenie_ocynku')
        grubosc = request.form.get('grubosc')
        szerokosc = request.form.get('szerokosc')
        nazwa = rodzaj + " " + grubosc_i_oznaczenie_ocynku + " " + szerokosc + "x" + grubosc
        
        nowy_szablon = Szablon(nazwa=nazwa, rodzaj=rodzaj, 
                               grubosc_i_oznaczenie_ocynku=grubosc_i_oznaczenie_ocynku, 
                               grubosc=grubosc, szerokosc=szerokosc)
        db.session.add(nowy_szablon)

        try:
            db.session.commit()
            logger.info(f"Szablon {nazwa} został dodany przez {g.user.login}.")
            return redirect(url_for('szablon'))  # Przekierowanie na stronę szablonów
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('szablon.html', error="Wystąpił błąd przy zapisywaniu danych.", user=g.user)

@app.route('/update-row-szablon', methods=['POST'])
def update_row_szablon():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    try:
        dane = request.get_json()
        logger.info(f'Otrzymane dane do aktualizacji szablonu: {dane}')

        id = dane.get('column_0')
        if id is None:
            return jsonify({'message': 'Id jest wymagane!'}), 400

        szablon = Szablon.query.get(id)
        if szablon is None:
            return jsonify({'message': 'Rekord nie znaleziony!'}), 404

        szablon.nazwa = dane.get('column_1', szablon.nazwa)
        szablon.rodzaj = dane.get('column_2', szablon.rodzaj)
        szablon.grubosc_i_oznaczenie_ocynku = dane.get('column_3', szablon.grubosc_i_oznaczenie_ocynku)
        szablon.grubosc = dane.get('column_5', szablon.grubosc)
        szablon.szerokosc = dane.get('column_4', szablon.szerokosc)

        tasma = Tasma.query.filter_by(szablon_id=id).all()
        for t in tasma:
            t.grubosc = szablon.grubosc
            t.szerokosc = szablon.szerokosc

        db.session.commit()
        logger.info(f"Szablon o ID {id} został zaktualizowany przez {g.user.login}.")
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'})
    except Exception as e:
        db.session.rollback()
        logger.error(f'Wystąpił błąd podczas aktualizacji: {str(e)}')
        return jsonify({'message': 'Wystąpił błąd podczas aktualizacji!', 'error': str(e)}), 500

@app.route('/zestawienie')
def zestawienie():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))

    logger.info(f"{g.user.login} wszedł na stronę zestawienia.")
    return render_template("zestawienie.html", user=g.user, profil=Profil.query.all(), tasma=Tasma.query.all())
@app.route('/log-download', methods=['POST'])
def log_download():
    data = request.json
    user = data.get('user', 'nieznany')
    columns = data.get('columns', [])
    app.logger.info(f"Pobranie pliku przez: {user} | Kolumny: {', '.join(columns)}")
    return '', 204  # No Content

@app.route('/download-excel', methods=['POST'])
def download_excel():
    data = request.json
    app.logger.info(f"Otrzymane dane: {data}")  # Logowanie otrzymanych danych
    headers = data.get('headers', [])
    rows = data.get('data', [])

    # Sprawdzenie, czy nagłówki i dane są poprawne
    if not headers or not rows:
        app.logger.error("Brak nagłówków lub danych do wygenerowania pliku Excel.")
        return jsonify({"error": "Brak nagłówków lub danych do wygenerowania pliku Excel."}), 400  # Zwraca status 400

    try:
        # Tworzymy nowy arkusz Excel
        wb = openpyxl.Workbook()
        ws = wb.active

        # Wiersz nagłówkowy - ustawiamy nagłówki w odpowiedniej kolejności
        ws.append(headers)

        # Dodajemy dane w odpowiedniej kolejności
        for row in rows:
            ws.append(row)

        # Zapis do bufora
        output = BytesIO()
        wb.save(output)
        output.seek(0)

        # Zwracamy plik Excel jako załącznik
        return send_file(output, as_attachment=True, download_name='raport.xlsx', mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    except Exception as e:
        app.logger.error(f"Błąd podczas generowania pliku Excel: {e}")
        return jsonify({"error": "Wystąpił błąd podczas generowania pliku Excel."}), 500  # Zwraca status 500
@app.route('/lokalizacja')
def lokalizacja():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    lokalizacja = Lokalizacja.query.all()
    logger.info(f"{g.user.login} wszedł na stronę dostawców.")
    return render_template("lokalizacje.html", user=g.user, lokalizacja=lokalizacja)

@app.route('/dodaj_lokalizacje')
def dodaj_lokalizacje():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))

    logger.info(f"{g.user.login} wszedł na stronę dodawania lokzlizacji.")
    return render_template("dodaj_lokalizacje.html", user=g.user)

@app.route('/dodaj_lokalizacje_do_bazy', methods=['POST'])
def dodaj_lokalizacje_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    if request.method == 'POST':
        nazwa = request.form.get('nazwa_lokalizacji')

        nowa_lokalizacja = Lokalizacja(nazwa=nazwa)
        db.session.add(nowa_lokalizacja)

        try:
            db.session.commit()
            logger.info(f"Lokalizacja {nazwa} został dodany przez {g.user.login}.")
            return redirect(url_for('lokalizacja'))  # Przekierowanie na stronę dostawców
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('lokalizacje.html', error="Wystąpił błąd przy zapisywaniu danych.", user=g.user)

@app.route('/update-row-lokalizacje', methods=['POST'])
def update_row_lokalizacje():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    try:
        dane = request.get_json()
        logger.info(f'Otrzymane dane do aktualizacji lokalizacji: {dane}')

        id = dane.get('column_0')
        if id is None:
            return jsonify({'message': 'Id jest wymagane!'}), 400

        lokalizacja = Lokalizacja.query.get(id)
        if lokalizacja is None:
            return jsonify({'message': 'Rekord nie znaleziony!'}), 404

        lokalizacja.nazwa = dane.get('column_1', lokalizacja.nazwa)

        db.session.commit()
        logger.info(f"Lokalizacja {lokalizacja.nazwa} został zaktualizowany przez {g.user.login}.")
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'})
    except Exception as e:
        db.session.rollback()
        logger.error(f'Wystąpił błąd podczas aktualizacji: {str(e)}')
        return jsonify({'message': 'Wystąpił błąd podczas aktualizacji!', 'error': str(e)}), 500
@app.route('/dlugosci')
def dlugosci():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    dlugosc = Dlugosci.query.all()
    logger.info(f"{g.user.login} wszedł na stronę dostawców.")
    return render_template("dlugosci.html", user=g.user, dlugosc=dlugosc)

@app.route('/dodaj_dlugosci')
def dodaj_dlugosci():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))

    logger.info(f"{g.user.login} wszedł na stronę dodawania lokzlizacji.")
    return render_template("dodaj_dlugosci.html", user=g.user)

@app.route('/dodaj_dlugosci_do_bazy', methods=['POST'])
def dodaj_dlugosci_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    if request.method == 'POST':
        nazwa = request.form.get('nazwa_dlugosci')

        nowa_dlugosc = Dlugosci(nazwa=nazwa)
        db.session.add(nowa_dlugosc)

        try:
            db.session.commit()
            logger.info(f"Dlugosc {nazwa} został dodany przez {g.user.login}.")
            return redirect(url_for('dlugosci'))  # Przekierowanie na stronę dostawców
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('dlugosci.html', error="Wystąpił błąd przy zapisywaniu danych.", user=g.user)

@app.route('/update-row-dlugosci', methods=['POST'])
def update_row_dlugosci():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    try:
        dane = request.get_json()
        logger.info(f'Otrzymane dane do aktualizacji dlugosci: {dane}')

        id = dane.get('column_0')
        if id is None:
            return jsonify({'message': 'Id jest wymagane!'}), 400

        dlugosc = Dlugosci.query.get(id)
        if lokalizacja is None:
            return jsonify({'message': 'Rekord nie znaleziony!'}), 404

        dlugosc.nazwa = dane.get('column_1', dlugosc.nazwa)

        db.session.commit()
        logger.info(f"Lokalizacja {dlugosc.nazwa} został zaktualizowany przez {g.user.login}.")
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'})
    except Exception as e:
        db.session.rollback()
        logger.error(f'Wystąpił błąd podczas aktualizacji: {str(e)}')
        return jsonify({'message': 'Wystąpił błąd podczas aktualizacji!', 'error': str(e)}), 500
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
