import smtplib
import ssl
from pathlib import Path
from jinja2 import Environment, FileSystemLoader, select_autoescape
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import os

project_root = Path(__file__).parent.parent.parent
template_dir = project_root / "templates"

env = Environment(
    loader=FileSystemLoader(template_dir),
    autoescape=select_autoescape(['html', 'xml']) # Enable autoescaping for security
)

def send_order_confirmation_email(user_email, items, total):
    sender_email = os.getenv("BNB_EMAIL_ADDRESS")
    app_password = os.getenv("BNB_EMAIL_PASSWORD")
    sender = os.getenv("BNB_EMAIL_USER")
    recipient_email = user_email

    print(template_dir)

    template = env.get_template('order_confirmation.html')
    html_body = template.render(items=items, total=total)

    message = MIMEMultipart("alternative")
    message["Subject"] = "Your Order Confirmation"
    message["From"] = sender_email
    message["To"] = recipient_email

    html_part = MIMEText(html_body, "html")
    message.attach(html_part)

    context = ssl.create_default_context()
    try:
        with smtplib.SMTP_SSL("thoth.csh.rit.edu", 465, context=context) as server:
            server.login(sender, app_password)
            server.sendmail(sender_email, recipient_email, message.as_string())
            print("HTML receipt sent successfully!")
    except Exception as e:
        print(f"Failed to send email: {e}")