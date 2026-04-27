import psycopg2

try:
    conn = psycopg2.connect(
        host="localhost",
        database="sales_management",
        user="postgres",
        password="thsvs123"
    )

    cursor = conn.cursor()

    # Insert payment
    cursor.execute("""
        INSERT INTO payment_splits 
        (sale_id, payment_date, amount_paid, payment_method)
        VALUES
        (3, '2025-04-11', 30000, 'UPI');
    """)

    conn.commit()

    print("✅ Payment inserted!")

except Exception as e:
    print("❌ Error:", e)