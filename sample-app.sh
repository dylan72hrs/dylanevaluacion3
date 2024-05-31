import hashlib
import sqlite3
from flask import Flask, request

app = Flask(__name__)

db_name = 'users.db'

@app.route('/')
def index():
    return 'Bienvenido al sistema de gestión de claves'

@app.route('/signup', methods=['POST'])
def signup():
    conn = sqlite3.connect(db_name)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS USERS
                 (USERNAME TEXT PRIMARY KEY NOT NULL,
                  HASH TEXT NOT NULL);''')
    conn.commit()
    username = request.form['username']
    password = request.form['password']
    hash_value = hashlib.sha256(password.encode()).hexdigest()
    try:
        c.execute("INSERT INTO USERS (USERNAME, HASH) VALUES (?, ?)", (username, hash_value))
        conn.commit()
    except sqlite3.IntegrityError:
        return "El usuario ya está registrado"
    return "Registro exitoso"

def verify(username, password):
    conn = sqlite3.connect(db_name)
    c = conn.cursor()
    query = "SELECT HASH FROM USERS WHERE USERNAME = ?"
    c.execute(query, (username,))
    records = c.fetchone()
    conn.close()
    if not records:
        return False
    return records[0] == hashlib.sha256(password.encode()).hexdigest()

@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    if verify(username, password):
        return "Inicio de sesión exitoso"
    return "Nombre de usuario o contraseña incorrectos"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=6000)
