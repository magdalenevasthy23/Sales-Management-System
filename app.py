# ---------------- IMPORTS ----------------
import streamlit as st
import psycopg2
import pandas as pd
import matplotlib.pyplot as plt
import os


# ---------------- DATABASE CONNECTION ----------------

def get_connection():
    return psycopg2.connect(
        host="localhost",
        database="sales_management",
        user="postgres",
        password="Your Password"
    )

conn = get_connection()
cursor = conn.cursor()


# ---------------- SESSION SETUP ----------------
def init_session():
    if "logged_in" not in st.session_state:
        st.session_state.logged_in = False
    if "user" not in st.session_state:
        st.session_state.user = None


# ---------------- AUTH FUNCTIONS ----------------
def login():
    st.title("🔐 Login")

    username = st.text_input("Username")
    password = st.text_input("Password", type="password")

    if st.button("Login"):
        cursor.execute(
            "SELECT * FROM users WHERE username=%s AND password=%s",
            (username, password)
        )
        user = cursor.fetchone()

        if user:
            st.session_state.logged_in = True
            st.session_state.user = user
            st.success("Login successful")
            st.rerun()
        else:
            st.error("Invalid credentials")


def logout():
    if st.button("Logout"):
        st.session_state.logged_in = False
        st.session_state.user = None
        st.rerun()


# ---------------- SQL QUESTIONS ----------------
def get_sql_questions():
    return {
        "1. Show all customer sales":
            "SELECT * FROM customer_sales",

        "2. Show all branches":
            "SELECT * FROM branches",

        "3. Show all payment splits":
            "SELECT * FROM payment_splits",

        "4. Show open sales":
            "SELECT * FROM customer_sales WHERE status='Open'",

        "5. Sales from Chennai branch":
            """SELECT cs.* FROM customer_sales cs
               JOIN branches b ON cs.branch_id = b.branch_id
               WHERE b.branch_name='Chennai'""",

        "6. Total gross sales":
            "SELECT SUM(gross_sales) AS total_sales FROM customer_sales",

        "7. Total received amount":
            "SELECT SUM(received_amount) FROM customer_sales",

        "8. Total pending amount":
            "SELECT SUM(gross_sales - received_amount) FROM customer_sales",

        "9. Sales count per branch":
            """SELECT b.branch_name, COUNT(*) 
               FROM customer_sales cs
               JOIN branches b ON cs.branch_id=b.branch_id
               GROUP BY b.branch_name""",

        "10. Average sales":
            "SELECT AVG(gross_sales) FROM customer_sales",

        "11. Sales with branch name":
            """SELECT cs.*, b.branch_name 
               FROM customer_sales cs
               JOIN branches b ON cs.branch_id=b.branch_id""",

        "12. Sales with total payments":
            """SELECT cs.sale_id, SUM(ps.amount_paid)
               FROM customer_sales cs
               JOIN payment_splits ps ON cs.sale_id = ps.sale_id
               GROUP BY cs.sale_id""",

        "13. Branch-wise total sales":
            """SELECT b.branch_name, SUM(cs.gross_sales)
               FROM customer_sales cs
               JOIN branches b ON cs.branch_id=b.branch_id
               GROUP BY b.branch_name""",

        "14. Sales with payment method":
            """SELECT cs.sale_id, ps.payment_method
               FROM customer_sales cs
               JOIN payment_splits ps ON cs.sale_id = ps.sale_id""",

        "15. Sales with admin name":
            """SELECT cs.sale_id, u.username
               FROM customer_sales cs
               JOIN users u ON cs.branch_id = u.branch_id"""
    }


# ---------------- SQL PAGE ----------------
def show_sql_page():
    st.title("SQL Analysis")

    st.info("Select a question and run the query")

    questions = get_sql_questions()

    selected_question = st.selectbox(
        "Choose SQL Question",
        list(questions.keys())
    )

    query = questions[selected_question]

    st.code(query, language="sql")

    if st.button("▶ Run Query"):
        try:
            cursor.execute(query)
            result = cursor.fetchall()

            if result:
                columns = [desc[0] for desc in cursor.description]
                df = pd.DataFrame(result, columns=columns)

                st.success("Query executed successfully")
                st.dataframe(df, use_container_width=True)
            else:
                st.warning("No data found")

        except Exception as e:
            st.error(f"Error: {e}")


# ---------------- DATA FETCH ----------------
def fetch_sales_data(role, branch_id):
    base_query = """
        SELECT cs.sale_id, cs.branch_id, b.branch_name, cs.date,
               cs.name, cs.mobile_num, cs.product_name,
               cs.gross_sales, cs.received_amount, cs.status
        FROM customer_sales cs
        JOIN branches b ON cs.branch_id = b.branch_id
    """

    if role == "Admin":
        base_query += " WHERE cs.branch_id = %s"
        cursor.execute(base_query, (branch_id,))
    else:
        cursor.execute(base_query)

    data = cursor.fetchall()

    columns = [
        "sale_id", "branch_id", "branch_name", "date",
        "name", "mobile_num", "product_name",
        "gross_sales", "received_amount", "status"
    ]

    return pd.DataFrame(data, columns=columns)


# ---------------- DATA PREP ----------------
def prepare_dataframe(df):
    if df.empty:
        st.warning("No data available")
        st.stop()

    df["gross_sales"] = pd.to_numeric(df["gross_sales"], errors="coerce").fillna(0)
    df["received_amount"] = pd.to_numeric(df["received_amount"], errors="coerce").fillna(0)
    df["date"] = pd.to_datetime(df["date"])

    return df


# ---------------- FILTERS ----------------
def apply_filters(df, role):
    st.subheader("🔍 Filters")

    col1, col2, col3 = st.columns(3)

    if role == "Super Admin":
        with col1:
            branches = ["All"] + sorted(df["branch_name"].unique())
            selected_branch = st.selectbox("Branch", branches)
    else:
        selected_branch = "All"

    with col2:
        products = ["All"] + sorted(df["product_name"].unique())
        selected_product = st.selectbox("Product", products)

    with col3:
        date_range = st.date_input(
            "Date Range",
            [df["date"].min(), df["date"].max()]
        )

    if selected_branch != "All":
        df = df[df["branch_name"] == selected_branch]

    if selected_product != "All":
        df = df[df["product_name"] == selected_product]

    if len(date_range) == 2:
        start, end = date_range
        df = df[(df["date"] >= pd.to_datetime(start)) &
                (df["date"] <= pd.to_datetime(end))]

    return df


# ---------------- KPI ----------------
def show_kpis(df):
    st.subheader("📌 Key Metrics")

    total_sales = df["gross_sales"].sum()
    total_received = df["received_amount"].sum()
    pending = total_sales - total_received

    col1, col2, col3 = st.columns(3)
    col1.metric("Total Sales", f"{total_sales:,.0f}")
    col2.metric("Total Received", f"{total_received:,.0f}")
    col3.metric("Pending", f"{pending:,.0f}")


# ---------------- TABLE ----------------
def show_table(df):
    st.subheader("📋 Sales Data")

    def format_status(val):
        if str(val).lower() == "closed":
            return "🟢 Closed"
        elif str(val).lower() == "open":
            return "🔴 Open"
        return val

    display_df = df.copy()
    display_df["status"] = display_df["status"].apply(format_status)

    st.dataframe(display_df, use_container_width=True)


# ---------------- CHARTS ----------------
def show_charts(df):
    st.subheader("📊 Sales by Branch")
    branch_sales = df.groupby("branch_name")["gross_sales"].sum()

    fig, ax = plt.subplots()
    branch_sales.plot(kind="bar", ax=ax)
    st.pyplot(fig)

    st.subheader("🥧 Status Distribution")
    status_counts = df["status"].value_counts()

    fig2, ax2 = plt.subplots()
    status_counts.plot(kind="pie", autopct="%1.1f%%", ax=ax2)
    ax2.set_ylabel("")
    st.pyplot(fig2)


# ---------------- PAYMENT FORM ----------------
def payment_form():
    st.subheader("💳 Add Payment")

    with st.form("payment_form"):
        sale_id = st.number_input("Sale ID", min_value=1)
        amount = st.number_input("Amount", min_value=0)
        method = st.selectbox("Method", ["Cash", "UPI", "Card"])

        if st.form_submit_button("Submit"):
            cursor.execute(
                "SELECT gross_sales, received_amount FROM customer_sales WHERE sale_id=%s",
                (sale_id,)
            )
            record = cursor.fetchone()

            if not record:
                st.error("Invalid Sale ID")
                return

            gross, received = record
            remaining = gross - received

            if remaining <= 0:
                st.warning("Already paid")
            elif amount > remaining:
                st.error(f"Exceeds remaining: {remaining}")
            else:
                cursor.execute("""
                    INSERT INTO payment_splits
                    (sale_id, payment_date, amount_paid, payment_method)
                    VALUES (%s, CURRENT_DATE, %s, %s)
                """, (sale_id, amount, method))

                conn.commit()
                st.success("Payment added")
                st.rerun()


# ---------------- ADD CUSTOMER ----------------
def add_customer_form(df):
    st.subheader("🧾 Add Customer Sale")

    with st.form("customer_form"):
        branch = st.selectbox("Branch", df["branch_name"].unique())
        name = st.text_input("Customer Name")
        mobile = st.text_input("Mobile Number")
        product = st.selectbox("Product", ["Laptop", "Mobile", "Tablet"])
        amount = st.number_input("Amount", min_value=0)

        if st.form_submit_button("Add"):
            if not name or not mobile:
                st.error("All fields required")
                return

            if len(mobile) != 10:
                st.error("Mobile must be 10 digits")
                return

            cursor.execute(
                "SELECT branch_id FROM branches WHERE branch_name=%s",
                (branch,)
            )
            branch_id = cursor.fetchone()[0]

            cursor.execute("""
                INSERT INTO customer_sales
                (branch_id, date, name, mobile_num, product_name,
                 gross_sales, received_amount, status)
                VALUES (%s, CURRENT_DATE, %s, %s, %s, %s, 0, 'open')
            """, (branch_id, name, mobile, product, amount))

            conn.commit()
            st.success("Customer added")
            st.rerun()


# ---------------- DASHBOARD ----------------
def show_dashboard(role, branch_id, user):
    st.title("📊 Sales Dashboard")

    col1, col2 = st.columns([3, 1])
    col1.write(f"Logged in as: {user[1]} ({role})")
    logout()

    df = fetch_sales_data(role, branch_id)
    df = prepare_dataframe(df)
    df = apply_filters(df, role)

    show_kpis(df)
    show_table(df)
    show_charts(df)

    if role in ["Admin", "Super Admin"]:
        payment_form()
        add_customer_form(df)


# ---------------- MAIN APP ----------------
def main():
    init_session()

    if not st.session_state.logged_in:
        login()
        return

    user = st.session_state.user
    role = user[4]
    branch_id = user[3]

    # 🔥 SIDEBAR NAVIGATION
    page = st.sidebar.radio("📂 Navigation", ["Dashboard", "SQL Analysis"])

    if page == "Dashboard":
        show_dashboard(role, branch_id, user)

    elif page == "SQL Analysis":
        show_sql_page()


# ---------------- RUN ----------------
if __name__ == "__main__":
    main()
