import datetime
from decimal import *
from dotenv import load_dotenv
import json
import pandas as pd
import psycopg2
import pytest
import os

load_dotenv()

db_name = 'project'
db_user = os.environ.get("DB_USER")
db_password = os.environ.get("DB_PASSWORD")
db_host = os.environ.get("DB_HOST")
db_port = os.environ.get("DB_PORT")

with open('./py_tests/queries.json') as file:
    test_queries = json.load(file)

@pytest.fixture
def db_connection():
    conn = psycopg2.connect(
        dbname=db_name,
        user=db_user,
        password=db_password,
        host=db_host,
        port=db_port
    )
    yield conn
    conn.close()

def test_1(db_connection):
    cursor = db_connection.cursor()
    cursor.execute(test_queries[0])
    result = cursor.fetchall()
    db_connection.commit()
    
    assert len(result) > 0
    assert len(result[0]) == 2

    df = pd.DataFrame(result, columns=['client_name', '	total_price'])

    assert df.shape[0] == 5
    assert df.iloc[0]['client_name'] == '"123 Инк." Александр Петров'
    assert df.iloc[2]['	total_price'] == 485070.00
    
    cursor.close()

def test_2(db_connection):
    cursor = db_connection.cursor()
    cursor.execute(test_queries[1])
    result = cursor.fetchall()
    db_connection.commit()

    assert len(result) > 0
    assert len(result[0]) == 3

    df = pd.DataFrame(result, columns=['client_id', 'client_name', 'orders_cnt'])

    assert df.shape[0] == 5
    assert df.iloc[0]['client_name'] == '"Компания ABC" Иван Иванов'
    assert df.iloc[3]['client_name'] == '"Смит и Ко." Ольга Белова'

    cursor.close()

def test_3(db_connection):
    cursor = db_connection.cursor()
    cursor.execute(test_queries[2])
    result = cursor.fetchall()
    db_connection.commit()

    assert len(result) > 0
    assert len(result[0]) == 3

    df = pd.DataFrame(result, columns=['order_id', 'address', 'start_date'])

    assert df.shape[0] == 2
    assert df.iloc[0]['order_id'] == 5
    assert df.iloc[1]['start_date'] == datetime.date(2024, 4, 21)

    cursor.close()

def test_4(db_connection):
    cursor = db_connection.cursor()
    cursor.execute(test_queries[3])
    result = cursor.fetchall()
    db_connection.commit()

    assert len(result) > 0
    assert len(result[0]) == 3

    df = pd.DataFrame(result, columns=['order_id', 'address', 'start_date'])

    assert df.shape[0] == 2
    assert df.iloc[0]['order_id'] == 7
    assert df.iloc[1]['address'] == "First Address for User 1"

    cursor.close()

def test_5(db_connection):
    cursor = db_connection.cursor()
    cursor.execute(test_queries[4])
    result = cursor.fetchall()
    db_connection.commit()

    assert len(result) > 0
    assert len(result[0]) == 3

    df = pd.DataFrame(result, columns=['product_id', 'name', 'free'])

    assert df.shape[0] == 25
    assert df.iloc[5]['name'] == 'Лист оцинкованный'
    assert df.iloc[1]['free'] == 8000

    cursor.close()

def test_6(db_connection):
    cursor = db_connection.cursor()
    cursor.execute(test_queries[5])
    result = cursor.fetchall()
    db_connection.commit()

    assert len(result) > 0
    assert len(result[0]) == 3

    df = pd.DataFrame(result, columns=['worker_name', 'contact_phone', 'client'])

    assert df.shape[0] == 19
    assert df.iloc[3]['worker_name'] == 'Анна Сидорова Александровна'
    assert df.iloc[1]['client'] == 'Роман Волков'
    assert df.iloc[5]['contact_phone'] == '+7(333)444-55-69'

    cursor.close()

def test_7(db_connection):
    cursor = db_connection.cursor()
    cursor.execute(test_queries[6])
    result = cursor.fetchall()
    db_connection.commit()

    assert len(result) > 0
    assert len(result[0]) == 4

    df = pd.DataFrame(result, columns=['worker_name', 'department_name', 'phone', 'email'])

    assert df.shape[0] == 1
    assert df.iloc[0]['worker_name'] == "Елена Козлова Викторовна"
    assert df.iloc[0]['department_name'] == "Отдел поддержки"
    assert df.iloc[0]['phone'] == "+7(444)444-44-44"

    cursor.close()

def test_8(db_connection):
    cursor = db_connection.cursor()
    cursor.execute(test_queries[7])
    result = cursor.fetchall()
    db_connection.commit()

    assert len(result) > 0
    assert len(result[0]) == 2

    df = pd.DataFrame(result, columns=['total_price', 'total_weight'])

    assert df.shape[0] == 1
    assert df.iloc[0]['total_price'] == 120685.00
    assert df.iloc[0]['total_weight'] == Decimal('1.180')

    cursor.close()

def test_9(db_connection):
    cursor = db_connection.cursor()
    cursor.execute(test_queries[8])
    result = cursor.fetchall()
    db_connection.commit()

    assert len(result) > 0
    assert len(result[0]) == 2

    df = pd.DataFrame(result, columns=['total_weight', 'cars'])

    assert df.shape[0] == 1
    assert df.iloc[0]['total_weight'] == Decimal('1.180')
    assert df.iloc[0]['cars'] == 3

    cursor.close()

def test_10(db_connection):
    cursor = db_connection.cursor()
    cursor.execute(test_queries[9])
    result = cursor.fetchall()
    db_connection.commit()
    
    assert len(result) > 0
    assert len(result[0]) == 2

    df = pd.DataFrame(result, columns=['client_name', 'address'])

    assert df.shape[0] == 19
    assert df.iloc[10]['client_name'] == '"Технологические Решения" Дмитрий Соколов'
    assert df.iloc[6]['address'] == 'Third Address for User 1'

    cursor.close()