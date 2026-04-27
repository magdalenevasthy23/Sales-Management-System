# Sales Management Dashboard

This project is a Sales Management Dashboard developed using Python, Streamlit, and PostgreSQL. The purpose of this application is to manage sales data in a structured way and present useful insights through an interactive and user-friendly interface.

Features:
-The application allows users to log in securely and access a dashboard where they can view key sales metrics such as total sales, received amount, and pending payments.
-Users can filter the data based on branch, product, and date to better understand trends and performance.
-In addition to the dashboard, the project also includes a SQL analysis section where different queries can be executed to explore the data more deeply.
-It also supports functionalities like adding new customer sales records and tracking payments, making it a complete mini sales management system.

This project is built using Python with Streamlit for the frontend interface, PostgreSQL as the backend database, and Pandas and Matplotlib for data processing and visualization. It demonstrates how different technologies can be combined to build a practical data-driven application.

**To access the application, you can use the following demo credentials:
Username: admin  
Password: admin123  **

To run the project locally, first install the required dependencies using the requirements.txt file. Then, set your PostgreSQL password as an environment variable. After that, run the Streamlit application using the command `streamlit run app.py`. Make sure your PostgreSQL server is running before starting the application.

For the database setup, you need to create a PostgreSQL database named `sales_management`. After creating the database, import the provided `database.sql` file using the command `psql -U postgres -d sales_management -f database.sql`. This will recreate all the necessary tables and sample data required for the project.

Please note that this project uses a local PostgreSQL database, and database credentials are not included in the code for security reasons.

Overall, this project showcases the implementation of a simple yet effective sales management system.
