from flask import Flask, render_template, request, redirect, url_for, g, make_response, flash, jsonify,  send_file,session
from flask_sqlalchemy import SQLAlchemy
import logging
from sqlalchemy import text, cast, Integer,Float
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
from datetime import datetime
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
class Szablon_profil(db.Model):
    __tablename__ = 'szablon_profile'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    nazwa = db.Column(db.String(255), nullable=False)
    waga_w_kg_na_1_metr = db.Column(db.Numeric(10, 2), nullable=False)

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
    id_szablon_profile = db.Column(db.Integer, db.ForeignKey('szablon_profile.id'), nullable=False)
    nazwa_klienta_nr_zlecenia_PRODIO = db.Column(db.String(100), nullable=True)
    ilosc=db.Column(db.Integer, nullable=False)
    ilosc_na_stanie = db.Column(db.Integer, nullable=True)
    id_dlugosci = db.Column(db.Integer, db.ForeignKey('dlugosci.id'), nullable=False)
    Data_do_usuwania = db.Column(db.Date, nullable=True)
    id_pracownika = db.Column(db.Integer, db.ForeignKey('uzytkownicy.id'), nullable=False)
    imie_nazwisko_pracownika = db.Column(db.String(50), nullable=False)
    tasma = db.relationship('Tasma', back_populates='profil')
    pracownik = db.relationship('Uzytkownik', back_populates='profil')
    dlugosci = db.relationship('Dlugosci', back_populates='profil')
    szablon_profile= db.relationship('Szablon_profil', backref='profil')
    def __repr__(self):
        return f"<Profil {self.id} - {self.id_szablon_profile}>"

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
class RozmiaryObejm(db.Model):
    __tablename__ = 'rozmiary_obejm'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    nazwa = db.Column(db.String(255), nullable=False)

    def __repr__(self):
        return f"<RozmiaryObejm {self.id} - {self.nazwa}>"


class MaterialObejma(db.Model):
    __tablename__ = 'material_obejma'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    certyfikat = db.Column(db.String(255))
    data_dostawy = db.Column(db.Date)
    nr_wytopu = db.Column(db.String(100))
    nr_prodio = db.Column(db.String(100))
    ilosc_sztuk = db.Column(db.Integer)
    ilosc_sztuk_na_stanie = db.Column(db.Integer)
    id_rozmiaru = db.Column(db.Integer, db.ForeignKey('rozmiary_obejm.id'))
    id_pracownik = db.Column(db.Integer, db.ForeignKey('uzytkownicy.id'))

    rozmiar = db.relationship('RozmiaryObejm')
    pracownik = db.relationship('Uzytkownik')

    def __repr__(self):
        return f"<MaterialObejma {self.id} - {self.nr_prodio}>"


class Ksztaltowanie(db.Model):
    __tablename__ = 'ksztaltowanie'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    rozmiar = db.Column(db.String(255))
    data = db.Column(db.Date)
    godzina_rozpoczecia = db.Column(db.Time)
    godzina_zakonczenia = db.Column(db.Time)
    ilosc = db.Column(db.Integer)
    ilosc_na_stanie = db.Column(db.Integer)
    nr_prodio = db.Column(db.String(100))
    id_materialu = db.Column(db.Integer, db.ForeignKey('material_obejma.id'))
    id_pracownik = db.Column(db.Integer, db.ForeignKey('uzytkownicy.id'))
    imie_nazwisko = db.Column(db.String(255))

    material = db.relationship('MaterialObejma')
    pracownik = db.relationship('Uzytkownik')

    def __repr__(self):
        return f"<Ksztaltowanie {self.id} - {self.nr_prodio}>"


class Malarnia(db.Model):
    __tablename__ = 'malarnia'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    id_ksztaltowanie = db.Column(db.Integer, db.ForeignKey('ksztaltowanie.id'))
    ilosc = db.Column(db.Integer)
    ilosc_na_stanie = db.Column(db.Integer)
    nr_prodio = db.Column(db.String(100))
    data = db.Column(db.Date)
    id_pracownik = db.Column(db.Integer, db.ForeignKey('uzytkownicy.id'))
    imie_nazwisko = db.Column(db.String(255))

    ksztaltowanie = db.relationship('Ksztaltowanie')
    pracownik = db.relationship('Uzytkownik')

    def __repr__(self):
        return f"<Malarnia {self.id} - {self.nr_prodio}>"


class Powrot(db.Model):
    __tablename__ = 'powrot'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    data = db.Column(db.Date)
    ilosc = db.Column(db.Integer)
    ilosc_na_stanie = db.Column(db.Integer)
    nr_prodio = db.Column(db.String(100))
    id_malowania = db.Column(db.Integer, db.ForeignKey('malarnia.id'))
    id_pracownik = db.Column(db.Integer, db.ForeignKey('uzytkownicy.id'))
    imie_nazwisko = db.Column(db.String(255))

    malarnia = db.relationship('Malarnia')
    pracownik = db.relationship('Uzytkownik')

    def __repr__(self):
        return f"<Powrot {self.id} - {self.nr_prodio}>"


class Zlecenie(db.Model):
    __tablename__ = 'zlecenie'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    nr_zamowienia_zew = db.Column(db.String(100))
    nr_prodio = db.Column(db.String(100))
    ile_pianki = db.Column(db.Integer)
    seria_tasmy = db.Column(db.String(100))
    ile_tasmy = db.Column(db.Integer)
    nr_kartonu = db.Column(db.String(100))
    id_pracownik = db.Column(db.Integer, db.ForeignKey('uzytkownicy.id'))
    imie_nazwisko = db.Column(db.String(255))

    pracownik = db.relationship('Uzytkownik')

    def __repr__(self):
        return f"<Zlecenie {self.id} - {self.nr_prodio}>"


class Laczenie(db.Model):
    __tablename__ = 'laczenie'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    id_zlecenie = db.Column(db.Integer, db.ForeignKey('zlecenie.id'))
    id_powrot = db.Column(db.Integer, db.ForeignKey('powrot.id'))
    ile_sztuk = db.Column(db.Integer)

    zlecenie = db.relationship('Zlecenie')
    powrot = db.relationship('Powrot')

    def __repr__(self):
        return f"<Laczenie {self.id} - {self.ile_sztuk} szt.>"
# Backup Directory
BACKUP_DIR = "backups"
INTERVAL_HOURS = 4
os.makedirs(BACKUP_DIR, exist_ok=True)

def format_sql_value(val):
    if val is None:
        return "NULL"
    return "'" + str(val).replace("'", "''") + "'"
def zapisz_do_pliku_sql():
    timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M')
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
                    'szablon_profile',
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
    user_id = session.get('user_id')
    if user_id is None:
        g.user = None
    else:
        g.user = Uzytkownik.query.get(user_id)

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
            logger.warning("Użytkownik z tym loginem "+login+" już istnieje.")
            return render_template('register.html', error="Użytkownik z tym loginem już istnieje.")

        nowy_uzytkownik = Uzytkownik(login=login, haslo=generate_password_hash(haslo), id_uprawnienia=uprawnienia)
        db.session.add(nowy_uzytkownik)

        try:
            db.session.commit()
            logger.info(f"Dane użytkownika {login} z uprawnieniami {Uprawnienia.query.get(uprawnienia).nazwa} zostały pomyślnie zapisane w bazie danych.")
            return redirect(url_for('uzytkownik'))  # Przekierowanie na stronę główną
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('register.html', error="Wystąpił błąd przy zapisywaniu danych.")

@app.route('/get-uprawnienia', methods=['GET'])
def get_uprawnienia():
    uprawnienia = Uprawnienia.query.all()
    return jsonify([{"id": u.id_uprawnienia, "nazwa": u.nazwa} for u in uprawnienia])
@app.route('/get-szablon_profile', methods=['GET'])
def get_szablon_profile():
    szablon_profil = Szablon_profil.query.all()
    return jsonify([{"id": s.id, "nazwa": s.nazwa} for s in szablon_profil])
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
    stary_login=Uzytkownik.query.get(user_id).login
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
    logger.info(f"Zaktualizowano dane użytkownika {stary_login}. Nowy login: {login}, Uprawnienia: {Uprawnienia.query.get(id_uprawnienia).nazwa}.")
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

        if user and check_password_hash(user.haslo, password):
            g.user = user
            session.clear()  # Czyścimy sesję przed nowym zalogowaniem
            session['user_id'] = user.id  # <-- tutaj zapisujemy user_id do session

            remember_me = request.form.get('remember_me')
            if remember_me:
                session.permanent = True  # <-- Sesja ważna dłużej (domyślnie 31 dni)
            else:
                session.permanent = False

            logger.info(f"Użytkownik {user.login} zalogowany pomyślnie.")
            return redirect(url_for('home'))
        else:
            logger.warning("Nieudana próba logowania.")
            return render_template('login.html', error="Błędny login lub hasło")

    return render_template('login.html')

@app.route('/logout')
def logout():
    if g.user:
        logger.info(f"Użytkownik {g.user.login} wylogowany.")
    session.clear()  # <-- czyścimy całą sesję
    return redirect(url_for('home'))





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
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    tasma = Tasma.query.get_or_404(id)
    
    try:
        db.session.delete(tasma)
        db.session.commit()
        logger.info(
            f"Taśma o ID {tasma.id} została usunięta przez użytkownika {g.user.login}. "
            f"Szczegóły taśmy: "
            f"Nr z etykiety na kręgu: {tasma.nr_z_etykiety_na_kregu}, "
            f"Data z etykiety na kręgu: {tasma.data_z_etykiety_na_kregu}, "
            f"Grubość: {tasma.grubosc}, "
            f"Szerokość: {tasma.szerokosc}, "
            f"Waga kręgu: {tasma.waga_kregu}, "
            f"Waga kręgu na stanie: {tasma.waga_kregu_na_stanie}, "
            f"Nr etykieta paletowa: {tasma.nr_etykieta_paletowa}, "
            f"Nr faktury dostawcy: {tasma.nr_faktury_dostawcy}, "
            f"Data dostawy: {tasma.data_dostawy}, "
            f"Lokalizacja: {tasma.lokalizacja.nazwa if tasma.lokalizacja else 'Brak'}, "
            f"Dostawca: {tasma.dostawca.nazwa if tasma.dostawca else 'Brak'}, "
            f"Szablon: {tasma.szablon.nazwa if tasma.szablon else 'Brak'}."
        )
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
        poprzednie_dane = {
            "dostawca_id": tasma.dostawca_id,
            "szablon_id": tasma.szablon_id,
            "data_z_etykiety_na_kregu": tasma.data_z_etykiety_na_kregu,
            "grubosc": tasma.grubosc,
            "szerokosc": tasma.szerokosc,
            "waga_kregu": tasma.waga_kregu,
            "waga_kregu_na_stanie": tasma.waga_kregu_na_stanie,
            "nr_etykieta_paletowa": tasma.nr_etykieta_paletowa,
            "nr_z_etykiety_na_kregu": tasma.nr_z_etykiety_na_kregu,
            "lokalizacja": tasma.lokalizacja.nazwa if tasma.lokalizacja else None,
            "nr_faktury_dostawcy": tasma.nr_faktury_dostawcy,
            "data_dostawy": tasma.data_dostawy
        }
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
        lokalizacja_id = dane.get('column_10')
        if lokalizacja_id:
            lokalizacja = db.session.get(Lokalizacja, lokalizacja_id)
            if lokalizacja:
                tasma.lokalizacja = lokalizacja
            else:
                tasma.lokalizacja = None
        tasma.nr_faktury_dostawcy = dane.get('column_11', tasma.nr_faktury_dostawcy)
        tasma.data_dostawy = dane.get('column_12', tasma.data_dostawy)

        db.session.commit()  # Zapisz zmiany w bazie
        nowe_dane = {
            "dostawca_id": tasma.dostawca_id,
            "szablon_id": tasma.szablon_id,
            "data_z_etykiety_na_kregu": tasma.data_z_etykiety_na_kregu,
            "grubosc": tasma.grubosc,
            "szerokosc": tasma.szerokosc,
            "waga_kregu": tasma.waga_kregu,
            "waga_kregu_na_stanie": tasma.waga_kregu_na_stanie,
            "nr_etykieta_paletowa": tasma.nr_etykieta_paletowa,
            "nr_z_etykiety_na_kregu": tasma.nr_z_etykiety_na_kregu,
            "lokalizacja": tasma.lokalizacja.nazwa if tasma.lokalizacja else None,
            "nr_faktury_dostawcy": tasma.nr_faktury_dostawcy,
            "data_dostawy": tasma.data_dostawy
        }
        logger.info(f"Poprzednie dane taśmy o ID {id}: {poprzednie_dane}")
        logger.info(f"Nowe dane taśmy o ID {id}: {nowe_dane}")
        logger.info(f"Zmiany wprowadzone przez użytkownika: {g.user.login}")
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
            logger.info(
                f"Taśma została dodana przez użytkownika {g.user.login}. "
                f"Szczegóły taśmy: "
                f"Dostawca ID: {dostawca_id}, Szablon ID: {szablon_id}, "
                f"Data z etykiety: {data_z_etykiety_na_kregu}, Grubość: {grubosc}, "
                f"Szerokość: {szerokosc}, Waga kręgu: {waga_kregu}, "
                f"Waga na stanie: {waga_kregu_na_stanie}, Nr etykieta paletowa: {nr_etykieta_paletowa}, "
                f"Nr z etykiety: {nr_z_etykiety_na_kregu}, Lokalizacja ID: {lokalizacja_id}, "
                f"Nr faktury dostawcy: {nr_faktury_dostawcy}, Data dostawy: {data_dostawy}."
            )
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
                           currentDate3=(date.today() - timedelta(days=3)).strftime('%Y-%m-%d'),
                            currentDate4=(date.today() - timedelta(days=4)).strftime('%Y-%m-%d'),
currentDate5=(date.today() - timedelta(days=5)).strftime('%Y-%m-%d'),
    
                            currentDate6=(date.today() - timedelta(days=6)).strftime('%Y-%m-%d'))


@app.route('/usun_profil/<int:id>', methods=['POST'])
def usun_profil(id):
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    profil = Profil.query.get_or_404(id)
    
    try:
        logger.info(
            f"Próba usunięcia profilu o ID {profil.id} przez użytkownika {g.user.login}. "
            f"Szczegóły profilu: "
            f"ID Taśmy: {profil.id_tasmy}, Data Produkcji: {profil.data_produkcji}, "
            f"Godzina rozpoczęcia: {profil.godz_min_rozpoczecia}, Godzina zakończenia: {profil.godz_min_zakonczenia}, "
            f"Zwrot na magazyn (kg): {profil.zwrot_na_magazyn_kg}, "
            f"ID Szablonu Profilu: {profil.id_szablon_profile}, "
            f"Nazwa Klienta: {profil.nazwa_klienta_nr_zlecenia_PRODIO}, "
            f"Ilość: {profil.ilosc}, Ilość na stanie: {profil.ilosc_na_stanie}, "
            f"ID Długości: {profil.id_dlugosci}."
        )
        db.session.delete(profil)
        db.session.commit()
        logger.info(f"Profil {profil.id_szablon_profile} został usunięty przez {g.user.login}.")
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
        poprzednie_dane = {
            "id_tasmy": profil.id_tasmy,
            "data_produkcji": profil.data_produkcji,
            "godz_min_rozpoczecia": profil.godz_min_rozpoczecia,
            "godz_min_zakonczenia": profil.godz_min_zakonczenia,
            "zwrot_na_magazyn_kg": profil.zwrot_na_magazyn_kg,
            "id_szablon_profile": profil.id_szablon_profile,
            "nazwa_klienta_nr_zlecenia_PRODIO": profil.nazwa_klienta_nr_zlecenia_PRODIO,
            "ilosc": profil.ilosc,
            "ilosc_na_stanie": profil.ilosc_na_stanie,
            "id_dlugosci": profil.id_dlugosci
        }
        # Aktualizacja pól w modelu Profil
        if 'column_1' in dane:
            profil.id_tasmy = dane['column_1']  # ID tasmy
        if 'column_2' in dane:
            profil.data_produkcji = dane['column_2']  # Data produkcji
        if 'column_4' in dane:
            profil.godz_min_rozpoczecia = dane['column_4']  # Godzina rozpoczęcia
        if 'column_5' in dane:
            profil.godz_min_zakonczenia = dane['column_5']  # Godzina zakończenia
        if 'column_6' in dane:
            profil.zwrot_na_magazyn_kg = dane['column_6']  # Zwrot na magazyn
        if 'column_7' in dane:
            profil.id_szablon_profile = dane['column_7']  # Nr części klienta
        if 'column_8' in dane:
            profil.nazwa_klienta_nr_zlecenia_PRODIO = dane['column_8']  # Nazwa klienta
        if 'column_9' in dane:
            profil.ilosc = dane['column_9']  # Ilość
        if 'column_10' in dane:
            profil.ilosc_na_stanie = dane['column_10'] # Ilość na stanie
        if 'column_11' in dane:
            profil.id_dlugosci = dane['column_11']  # ID długości
        nowe_dane = {
            "id_tasmy": profil.id_tasmy,
            "data_produkcji": profil.data_produkcji,
            "godz_min_rozpoczecia": profil.godz_min_rozpoczecia,
            "godz_min_zakonczenia": profil.godz_min_zakonczenia,
            "zwrot_na_magazyn_kg": profil.zwrot_na_magazyn_kg,
            "id_szablon_profile": profil.id_szablon_profile,
            "nazwa_klienta_nr_zlecenia_PRODIO": profil.nazwa_klienta_nr_zlecenia_PRODIO,
            "ilosc": profil.ilosc,
            "ilosc_na_stanie": profil.ilosc_na_stanie,
            "id_dlugosci": profil.id_dlugosci
        }   
        logger.info(f"Poprzednie dane profilu o ID {id}: {poprzednie_dane}")
        logger.info(f"Nowe dane profilu o ID {id}: {nowe_dane}")
        logger.info(f"Zmiany wprowadzone przez użytkownika: {g.user.login}")
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
    szablony=Szablon_profil.query.all()
    logger.info(f"{g.user.login} wszedł na stronę dodawania profilu.")
    return render_template("dodaj_profil.html", user=g.user, tasmy=tasmy,dlugosci=dlugosci,szablony=szablony)

@app.route('/dodaj_lub_zakonczenie_profilu', methods=['GET', 'POST'])
def dodaj_lub_zakonczenie_profilu():
    if not g.user:
        return render_template('login.html')

    profil_id = request.form.get('profil_id')

    if profil_id:
        # ZAKOŃCZENIE
        profil = Profil.query.get(profil_id)
        poprzednie_dane = {
                "godz_min_zakonczenia": profil.godz_min_zakonczenia,
                "zwrot_na_magazyn_kg": profil.zwrot_na_magazyn_kg,
                "ilosc": profil.ilosc,
                "ilosc_na_stanie": profil.ilosc_na_stanie,
                "id_dlugosci": profil.id_dlugosci
            }
        profil.godz_min_zakonczenia = request.form.get('godz_min_zakonczenia')
        
        profil.ilosc = request.form.get('ilosc')
        profil.ilosc_na_stanie = request.form.get('ilosc')
        profil.id_dlugosci = request.form.get('id_dlugosci')
        if request.form.get('zwrot_na_magazyn_kg') == "":
            
            ilosc = int(request.form.get('ilosc'))     # sztuki
            dlugosci = Dlugosci.query.get(int(request.form.get('id_dlugosci')))
            dlugosc = float(dlugosci.nazwa)             # mm, zakładam że 'dlugosc' to pole

            profil.zwrot_na_magazyn_kg = profil.tasma.waga_kregu_na_stanie - Decimal(ilosc *float(profil.szablon_profile.waga_w_kg_na_1_metr))  # kg
        else:
            profil.zwrot_na_magazyn_kg = float(request.form.get('zwrot_na_magazyn_kg'))
        tasma = Tasma.query.get(profil.id_tasmy)
        tasma.waga_kregu_na_stanie = float(profil.zwrot_na_magazyn_kg)
        nowe_dane = {
                "godz_min_zakonczenia": profil.godz_min_zakonczenia,
                "zwrot_na_magazyn_kg": profil.zwrot_na_magazyn_kg,
                "ilosc": profil.ilosc,
                "ilosc_na_stanie": profil.ilosc_na_stanie,
                "id_dlugosci": profil.id_dlugosci
            }

        logger.info(f"Zakończenie profilu o ID {profil_id} przez użytkownika {g.user.login}.")
        logger.info(f"Poprzednie dane: {poprzednie_dane}")
        logger.info(f"Nowe dane: {nowe_dane}")

    else:
        # ROZPOCZĘCIE
        profil = Profil(
            id_tasmy=request.form.get('etykieta'),
            data_produkcji=request.form.get('data_produkcji'),
            godz_min_rozpoczecia=request.form.get('godz_min_rozpoczecia'),
            id_szablon_profile=request.form.get('szablon_profile'),
            nazwa_klienta_nr_zlecenia_PRODIO=request.form.get('nazwa_klienta_nr_zlecenia_PRODIO'),
            id_pracownika=g.user.id,
            imie_nazwisko_pracownika=request.form.get('imie_nazwisko_pracownika'),
            Data_do_usuwania=date.today() + timedelta(days=365)
        )
        db.session.add(profil)
        tasma = Tasma.query.get(profil.id_tasmy)
        

        logger.info(f"Nowy profil został dodany przez użytkownika {g.user.login}.")
        logger.info(
            f"Szczegóły profilu: ID Taśmy: {profil.id_tasmy}, Data Produkcji: {profil.data_produkcji}, "
            f"Godzina rozpoczęcia: {profil.godz_min_rozpoczecia}, ID Szablonu Profilu: {profil.id_szablon_profile}, "
            f"Nazwa Klienta: {profil.nazwa_klienta_nr_zlecenia_PRODIO}, Ilość: {profil.ilosc}, "
            f"ID Długości: {profil.id_dlugosci}."
            f"Imie nazwisko pracownika: {profil.imie_nazwisko_pracownika}."
            )
    try:
        db.session.commit()
        return redirect(url_for('profil'))
    except Exception as e:
        db.session.rollback()
        return f"Błąd zapisu: {e}"
@app.route('/dodaj_profil_do_bazy', methods=['GET', 'POST'])
def dodaj_profil_do_bazy():
    if not g.user:
        return render_template('login.html')

    # Odbierz 'profil_id' z formularza (z ukrytego pola)
    profil_id = request.form.get('profil_id')
    profil = Profil.query.get(profil_id) if profil_id else None

    # Zwróć dane do szablonu
    tasmy = Tasma.query.all()
    dlugosci = Dlugosci.query.all()
    teraz = datetime.now().strftime('%H:%M:%S')
    dzisiaj = date.today().strftime('%Y-%m-%d')

    return render_template(
        'dodaj_profil.html',
        user=g.user,
        profil=profil,
        tasma=tasmy,
        dlugosci=dlugosci,
        teraz=teraz,
        dzisiaj=dzisiaj,
        szablony=Szablon_profil.query.all(),
        ilosc=Tasma.query.get(profil.id_tasmy).waga_kregu_na_stanie if profil else None
    )
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
    
    if g.user.id_uprawnienia == 3:
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
        
        poprzednie_dane = {
            "id": dostawca.id,
            "nazwa": dostawca.nazwa
        }
        logger.info(f"Poprzednie dane dostawcy o ID {id}: {poprzednie_dane}")
        
        dostawca.nazwa = dane.get('column_1', dostawca.nazwa)

        db.session.commit()
        logger.info(f"Dostawca {dostawca.nazwa} został zaktualizowany przez {g.user.login}.")
        
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'}), 200  # Dodany status 200 OK
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
        poprzednie_dane = {
            "id": szablon.id,
            "nazwa": szablon.nazwa,
            "rodzaj": szablon.rodzaj,
            "grubosc_i_oznaczenie_ocynku": szablon.grubosc_i_oznaczenie_ocynku,
            "grubosc": szablon.grubosc,
            "szerokosc": szablon.szerokosc
        }
        logger.info(f"Poprzednie dane szablonu o ID {id}: {poprzednie_dane}")
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
        nowe_dane = {
            "id": szablon.id,
            "nazwa": szablon.nazwa,
            "rodzaj": szablon.rodzaj,
            "grubosc_i_oznaczenie_ocynku": szablon.grubosc_i_oznaczenie_ocynku,
            "grubosc": szablon.grubosc,
            "szerokosc": szablon.szerokosc
        }
        logger.info(f"Nowe dane szablonu o ID {id}: {nowe_dane}")
        logger.info(f"Szablon o ID {id} został zaktualizowany przez użytkownika {g.user.login}.")

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
        poprzednie_dane = {"id": lokalizacja.id, "nazwa": lokalizacja.nazwa}
        logger.info(f"Poprzednie dane lokalizacji o ID {id}: {poprzednie_dane}")
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
        poprzednie_dane = {"id": dlugosc.id, "nazwa": dlugosc.nazwa}
        logger.info(f"Poprzednie dane długości o ID {id}: {poprzednie_dane}")
        dlugosc.nazwa = dane.get('column_1', dlugosc.nazwa)

        db.session.commit()
        logger.info(f"Lokalizacja {dlugosc.nazwa} został zaktualizowany przez {g.user.login}.")
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'})
    except Exception as e:
        db.session.rollback()
        logger.error(f'Wystąpił błąd podczas aktualizacji: {str(e)}')
        return jsonify({'message': 'Wystąpił błąd podczas aktualizacji!', 'error': str(e)}), 500
@app.route('/szablon_profil')
def szablon_profil():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    szablon_profil = Szablon_profil.query.all()
    logger.info(f"{g.user.login} wszedł na stronę szablonów.")
    return render_template("szablon_profil.html", user=g.user, szablon_profil=szablon_profil)
@app.route('/dodaj_szablon_profil')
def dodaj_szablon_profil():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))

    logger.info(f"{g.user.login} wszedł na stronę dodawania szablonu.")
    return render_template("dodaj_szablon_profil.html", user=g.user)
@app.route('/dodaj_szablon_profil_do_bazy', methods=['POST'])
def dodaj_szablon_profil_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia ==3:
        return redirect(url_for('home'))
    
    if request.method == 'POST':
        nazwa = request.form.get('nazwa_szablonu')
        waga_w_kg_na_1_metr = request.form.get('waga')
        
        nowy_szablon_profil = Szablon_profil(nazwa=nazwa,waga_w_kg_na_1_metr=waga_w_kg_na_1_metr)
        db.session.add(nowy_szablon_profil)

        try:
            db.session.commit()
            logger.info(f"Szablon {nazwa} został dodany przez {g.user.login}.")
            return redirect(url_for('szablon_profil'))  # Przekierowanie na stronę szablonów
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('szablon_profil.html', error="Wystąpił błąd przy zapisywaniu danych.", user=g.user)
@app.route('/update-row-szablon_profil', methods=['POST'])
def update_row_szablon_profil():
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

        szablon_profil = Szablon_profil.query.get(id)
        if szablon_profil is None:
            return jsonify({'message': 'Rekord nie znaleziony!'}), 404
        poprzednie_dane = {
            "id": szablon_profil.id,
            "nazwa": szablon_profil.nazwa,
            "waga_w_kg_na_1_metr": szablon_profil.waga_w_kg_na_1_metr
        }
        logger.info(f"Poprzednie dane szablonu o ID {id}: {poprzednie_dane}")
        szablon_profil.nazwa = dane.get('column_1', szablon_profil.nazwa)
        szablon_profil.waga_w_kg_na_1_metr = dane.get('column_2', szablon_profil.waga_w_kg_na_1_metr)


        db.session.commit()
        logger.info(f"Szablon o ID {id} został zaktualizowany przez {g.user.login}.")
        return jsonify({'message': 'Rekord zaktualizowany pomyślnie!'})
    except Exception as e:
        db.session.rollback()
        logger.error(f'Wystąpił błąd podczas aktualizacji: {str(e)}')
        return jsonify({'message': 'Wystąpił błąd podczas aktualizacji!', 'error': str(e)}), 500
@app.route('/sprzedaz', methods=["GET", "POST"])
def sprzedaz():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))

    wszystkie_profile = []
    dlugosci = Dlugosci.query.all()

    if request.method == "POST":
        try:
            dlugosc_id = int(request.form.get('dlugosc_id'))
        except (TypeError, ValueError):
            flash("Nieprawidłowe dane wejściowe.")
            logger.warning(f"Nieprawidłowe dane wejściowe od użytkownika {g.user.login}")
            return redirect(url_for('sprzedaz'))

        wybrana_dlugosc = Dlugosci.query.get(dlugosc_id)
        if not wybrana_dlugosc:
            flash("Nie wybrano długości.")
            logger.warning(f"Nie wybrano długości przez użytkownika {g.user.login}")
            return redirect(url_for('sprzedaz'))

        # Zamiana przecinka na kropkę i konwersja do float
        try:
            dlugosc_wartosc = float(wybrana_dlugosc.nazwa.replace(',', '.'))
        except ValueError:
            flash("Błąd w formacie długości.")
            logger.error(f"Błąd konwersji długości '{wybrana_dlugosc.nazwa}' na liczbę przez użytkownika {g.user.login}")
            return redirect(url_for('sprzedaz'))

        logger.info(f"Użytkownik {g.user.login} wybrał długość {dlugosc_wartosc}")

        # Profile dokładnie pasujące
        dostepne_profile = Profil.query.filter(
            Profil.id_dlugosci == dlugosc_id,
            Profil.ilosc_na_stanie > 0
        ).all()

        for p in dostepne_profile:
            p.ciecie = False
            p.uwaga = "Brak"
            p.mozliwa_ilosc = p.ilosc_na_stanie
            logger.info(f"[DOSTĘPNE] Profil ID {p.id}, długość {p.dlugosci.nazwa}, na stanie {p.ilosc_na_stanie}")

        # Profile większe — możliwe do pocięcia
        wszystkie_dlugosci = Dlugosci.query.all()

        wieksze_dlugosci = []
        for d in wszystkie_dlugosci:
            try:
                wartosc = float(d.nazwa.replace(',', '.'))
                if wartosc > dlugosc_wartosc:
                    wieksze_dlugosci.append(d)
            except ValueError:
                logger.error(f"Błąd parsowania długości '{d.nazwa}' (id={d.id})")
                continue

        wieksze_ids = [d.id for d in wieksze_dlugosci]

        profile_do_ciecia = Profil.query.filter(
            Profil.id_dlugosci.in_(wieksze_ids),
            Profil.ilosc_na_stanie > 0
        ).all()

        for p in profile_do_ciecia:
            p.ciecie = True
            try:
                wieksza_dlugosc = float(p.dlugosci.nazwa.replace(',', '.'))
                ile_sie_da_zrobic = int(wieksza_dlugosc // dlugosc_wartosc)
                p.uwaga = f"Można ciąć na mniejsze profile (max {ile_sie_da_zrobic} szt. z jednej)"
                p.mozliwa_ilosc = p.ilosc_na_stanie * ile_sie_da_zrobic
                logger.info(f"[CIĘCIE] Profil ID {p.id}, długość {p.dlugosci.nazwa}, na stanie {p.ilosc_na_stanie}, "
                            f"możliwe do uzyskania: {p.mozliwa_ilosc}")
            except (ValueError, ZeroDivisionError):
                logger.error(f"Błąd obliczania cięcia dla profilu ID {p.id}")
                continue

        wszystkie_profile = dostepne_profile + profile_do_ciecia

    return render_template(
        "sprzedaz.html",
        user=g.user,
        dlugosci=dlugosci,
        wszystkie_profile=wszystkie_profile
    )


@app.route('/wez_profile', methods=["POST"])
def wez_profile():
    if not g.user:
        return redirect(url_for('login'))

    profile = Profil.query.all()
    for profil in profile:
        ilosc_do_pobrania = request.form.get(f'ilosc_wez_{profil.id}')
        if ilosc_do_pobrania:
            try:
                ilosc = int(ilosc_do_pobrania)
                if 0 < ilosc <= (profil.ilosc_na_stanie or 0):
                    logger.info(f"Użytkownik {g.user.login} pobiera {ilosc} sztuk z profilu ID {profil.id} "
                                f"(długość: {profil.dlugosci.nazwa}, stan przed: {profil.ilosc_na_stanie})")
                    profil.ilosc_na_stanie -= ilosc
                    db.session.add(profil)
                else:
                    logger.warning(f"Nieprawidłowa ilość: {ilosc} dla profilu ID {profil.id} przez użytkownika {g.user.login}")
            except ValueError:
                logger.error(f"Błąd parsowania ilości dla profilu ID {profil.id}")
                continue

    db.session.commit()
    logger.info(f"Użytkownik {g.user.login} zakończył pobieranie profili.")
    flash("Profile zostały pobrane.")
    return redirect(url_for('sprzedaz'))
@app.route('/uprawnienia', methods=["POST"])
def uprawnienia():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia != 1:
        return redirect(url_for('home'))

    uprawnienia = Uprawnienia.query.all()
    logger.info(f"{g.user.login} wszedł na stronę uprawnień.")
    return render_template("uprawnienia.html", user=g.user, uprawnienia=uprawnienia)
@app.route('/rozmiary_obejm')
def rozmiary_obejm():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    rozmiary = RozmiaryObejm.query.all()
    logger.info(f"{g.user.login} wszedł na stronę rozmiarów obejm.")
    return render_template("rozmiary_obejm.html", user=g.user, rozmiary=rozmiary)
@app.route('/dodaj_rozmiar_obejma')
def dodaj_rozmiar_obejma():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    logger.info(f"{g.user.login} wszedł na stronę dodawania rozmiaru obejm.")
    return render_template("dodaj_rozmiar_obejma.html", user=g.user)
@app.route('/dodaj_rozmiar_obejma_do_bazy', methods=['POST'])
def dodaj_rozmiar_obejma_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    if request.method == 'POST':
        nazwa = request.form.get('rozmiar_obejm')
        
        
        nowy_rozmiar = RozmiaryObejm(nazwa=nazwa)
        db.session.add(nowy_rozmiar)

    try:
        db.session.commit()
        logger.info(f"Rozmiar {nazwa} został dodany przez {g.user.login}.")
        return redirect(url_for('rozmiary_obejm'))  # Przekierowanie na stronę rozmiarów obejm
    except Exception as e:
        db.session.rollback()
        logger.error(f"Nie udało się zapisać danych: {e}")
        return render_template('rozmiary_obejm.html', error="Wystąpił błąd przy zapisywaniu danych.", user=g.user)

@app.route('/material_obejma')
def material_obejma():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    meterial = MaterialObejma.query.all()
    logger.info(f"{g.user.login} wszedł na stronę materialów obejm.")
    return render_template("material_obejma.html", user=g.user, meterial=meterial)
@app.route('/dodaj_material_obejma')
def dodaj_material_obejma():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    logger.info(f"{g.user.login} wszedł na stronę dodawania materiału obejm.")
    return render_template("dodaj_material_obejma.html", user=g.user, rozmiar=RozmiaryObejm.query.all())
@app.route('/dodaj_material_obejma_do_bazy', methods=['POST'])
def dodaj_material_obejma_do_bazy():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    if request.method == 'POST':
        certyfikat = request.form.get('certyfikat')
        data= request.form.get('data')
        numer_wytopu = request.form.get('wytop')
        numer_prodio=request.form.get('prodio')
        ilosc = request.form.get('ilosc')
        ilosc_na_stanie = request.form.get('ilosc')
        pracownik=g.user.id
        id_rozmiar = request.form.get('nazwa_materiału')
        
        
        nowy_material = MaterialObejma(certyfikat=certyfikat, data_dostawy=data, nr_wytopu=numer_wytopu,
                                      nr_prodio=numer_prodio, ilosc_sztuk=ilosc, ilosc_sztuk_na_stanie=ilosc_na_stanie,id_rozmiaru=id_rozmiar, id_pracownik=pracownik)
        db.session.add(nowy_material)
        try:
            db.session.commit()
            logger.info(f"Materiał {certyfikat} został dodany przez {g.user.login}.")
            return redirect(url_for('material_obejma'))  # Przekierowanie na stronę materiałów obejm
        except Exception as e:
            db.session.rollback()
            logger.error(f"Nie udało się zapisać danych: {e}")
            return render_template('material_obejma.html', error="Wystąpił błąd przy zapisywaniu danych.", user=g.user)

@app.route('/ksztaltowanie')
def ksztaltowanie():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    ksztaltowanie = Ksztaltowanie.query.all()
    logger.info(f"{g.user.login} wszedł na stronę ksztaltowania.")
    return render_template("ksztaltowanie.html", user=g.user, ksztaltowanie=ksztaltowanie)
@app.route('/dodaj_ksztaltowanie')
def dodaj_ksztaltowanie():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    logger.info(f"{g.user.login} wszedł na stronę dodawania ksztaltowania.")
    return render_template("dodaj_ksztaltowanie.html", user=g.user)

@app.route('/malarnia')
def malarnia():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    malarnia = Malarnia.query.all()
    logger.info(f"{g.user.login} wszedł na stronę malarni.")
    return render_template("malarnia.html", user=g.user, malarnia=malarnia)
@app.route('/dodaj_malarnie')
def dodaj_malarnie():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    logger.info(f"{g.user.login} wszedł na stronę dodawania malarni.")
    return render_template("dodaj_malarnie.html", user=g.user)


@app.route('/powrot')
def powrot():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    powrot = Powrot.query.all()
    logger.info(f"{g.user.login} wszedł na stronę powrotu.")
    return render_template("powrot.html", user=g.user, powrot=powrot)
@app.route('/dodaj_powrot')
def dodaj_powrot():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    logger.info(f"{g.user.login} wszedł na stronę dodawania powrotu.")
    return render_template("dodaj_powrot.html", user=g.user)


@app.route('/zlecenie')
def zlecenie():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    zlecenie = Zlecenie.query.all()
    logger.info(f"{g.user.login} wszedł na stronę zlecenia.")
    return render_template("zlecenie.html", user=g.user, zlecenie=zlecenie)
@app.route('/dodaj_zlecenie')
def dodaj_zlecenie():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    logger.info(f"{g.user.login} wszedł na stronę dodawania zlecenia.")
    return render_template("dodaj_zlecenie.html", user=g.user)


@app.route('/laczenie')
def laczenie():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    laczenie = Laczenie.query.all()
    logger.info(f"{g.user.login} wszedł na stronę Łączenia.")
    return render_template("zlecenie.html", user=g.user, laczenie=laczenie)
@app.route('/dodaj_laczenie')
def dodaj_laczenie():
    if not g.user:
        return render_template('login.html', user=g.user)
    if g.user.id_uprawnienia == 3:
        return redirect(url_for('home'))
    
    logger.info(f"{g.user.login} wszedł na stronę dodawania łączenia.")
    return render_template("dodaj_laczenie.html", user=g.user)
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
