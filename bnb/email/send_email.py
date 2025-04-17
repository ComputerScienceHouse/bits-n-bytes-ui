import smtplib
import ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import os

ITEM_HTML_TEMPLATE="""
<table align="center" border="0" cellpadding="0" cellspacing="0" class="row-content stack" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #FFFFFF; color: #333; width: 620px; margin: 0 auto;" width="620">
<tbody>
<tr>
<td class="column column-1" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; font-weight: 400; text-align: left; padding-top: 15px; vertical-align: top;" width="66.66666666666667%">
<table border="0" cellpadding="0" cellspacing="0" class="paragraph_block block-1" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; word-break: break-word;" width="100%">
<tr>
<td class="pad" style="padding-bottom:10px;padding-left:20px;padding-right:20px;padding-top:10px;">
<div style="color:#000000;font-family:'Lato', Tahoma, Verdana, Segoe, sans-serif;font-size:14px;line-height:1.2;text-align:left;mso-line-height-alt:17px;">
<p style="margin: 0; word-break: break-word;"><span style="word-break: break-word; color: rgb(0,0,0);"><a data-mce-style="text-decoration: none; color: #000000;" style="text-decoration: none; color: #71777D;" target="_blank">{quantity} x {name}</a></span></p>
</div>
</td>
</tr>
</table>
</td>
<td class="column column-2" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; font-weight: 400; text-align: left; padding-top: 15px; vertical-align: top;" width="33.333333333333336%">
<table border="0" cellpadding="0" cellspacing="0" class="paragraph_block block-1" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; word-break: break-word;" width="100%">
<tr>
<td class="pad" style="padding-bottom:10px;padding-left:20px;padding-right:20px;padding-top:10px;">
<div style="color:#000000;font-family:'Lato', Tahoma, Verdana, Segoe, sans-serif;font-size:14px;line-height:1.2;text-align:left;mso-line-height-alt:17px;">
<p style="margin: 0; word-break: break-word;">${price:.2f}</p>
</div>
</td>
</tr>
</table>
</td>
</tr>
</tbody>
</table>"""

TOTAL_HTML_TEMPLATE="""
<table align="center" border="0" cellpadding="0" cellspacing="0" class="row row-8" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt;" width="100%">
<tbody>
<tr>
<td>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="row-content stack" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; color: #000000; width: 620px; margin: 0 auto;" width="620">
<tbody>
<tr>
<td class="column column-1" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; font-weight: 400; text-align: left; padding-bottom: 5px; padding-top: 5px; vertical-align: top;" width="100%">
<table border="0" cellpadding="10" cellspacing="0" class="divider_block block-1" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt;" width="100%">
<tr>
<td class="pad">
<div align="center" class="alignment">
<table border="0" cellpadding="0" cellspacing="0" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt;" width="100%">
<tr>
<td class="divider_inner" style="font-size: 1px; line-height: 1px; border-top: 1px dotted #CCCCCC;"><span style="word-break: break-word;"> </span></td>
</tr>
</table>
</div>
</td>
</tr>
</table>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="row row-9" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt;" width="100%">
<tbody>
<tr>
<td>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="row-content stack" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #FFFFFF; color: #333; width: 620px; margin: 0 auto;" width="620">
<tbody>
<tr>
<td class="column column-1" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; font-weight: 400; text-align: left; padding-top: 5px; vertical-align: top;" width="66.66666666666667%">
<table border="0" cellpadding="0" cellspacing="0" class="paragraph_block block-1" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; word-break: break-word;" width="100%">
<tr>
<td class="pad" style="padding-bottom:5px;padding-left:20px;padding-right:20px;padding-top:5px;">
<div style="color:#000000;font-family:'Lato', Tahoma, Verdana, Segoe, sans-serif;font-size:14px;line-height:1.2;text-align:left;mso-line-height-alt:17px;">
<p style="margin: 0; word-break: break-word;"><strong>TOTAL</strong><br/></p>
</div>
</td>
</tr>
</table>
</td>
<td class="column column-2" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; font-weight: 400; text-align: left; padding-top: 5px; vertical-align: top;" width="33.333333333333336%">
<table border="0" cellpadding="0" cellspacing="0" class="paragraph_block block-1" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; word-break: break-word;" width="100%">
<tr>
<td class="pad" style="padding-bottom:5px;padding-left:20px;padding-right:20px;padding-top:5px;">
<div style="color:#000000;font-family:'Lato', Tahoma, Verdana, Segoe, sans-serif;font-size:14px;line-height:1.2;text-align:left;mso-line-height-alt:17px;">
<p style="margin: 0; word-break: break-word;"><strong>${total:.2f}</strong></p>
</div>
</td>
</tr>
</table>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
"""

def send_order_confirmation_email(user_email, items, total):
    sender_email = os.getenv("BNB_EMAIL")
    app_password = os.getenv("BNB_EMAIL_PASSWORD")
    recipient_email = user_email

    message = MIMEMultipart("alternative")
    message["Subject"] = "Your Order Confirmation"
    message["From"] = sender_email
    message["To"] = recipient_email

    script_dir = os.path.dirname(os.path.realpath(__file__))
    image_folder = os.path.join(script_dir, 'images')

    # Replace image paths in header and footer HTML
    with open(os.path.join(script_dir, 'header.html'), 'r') as header_file:
        header_html = header_file.read()
    header_html = header_html.replace('src="bnblogohoriz.png"', f'src="{os.path.join(image_folder, "bnblogohoriz.png")}"')
    header_html = header_html.replace('src="okok.gif"', f'src="{os.path.join(image_folder, "okok.gif")}"')

    with open(os.path.join(script_dir, 'footer.html'), 'r') as footer_file:
        footer_html = footer_file.read()
    footer_html = footer_html.replace('src="beefree-logo.png"', f'src="{os.path.join(image_folder, "beefree-logo.png")}"')

    item_rows = ""
    for item in items:
        item_rows += ITEM_HTML_TEMPLATE.format(**item)

    total_html = TOTAL_HTML_TEMPLATE.format(total=total)

    html_body = f"""{header_html}{item_rows}{total_html}{footer_html}"""

    with open('email_template.html', 'w') as f:
        f.write(html_body)

    # TODO: Will uncomment this when we get the email from OpComm
    html_part = MIMEText(html_body, "html")
    message.attach(html_part)

    context = ssl.create_default_context()
    try:
        with smtplib.SMTP_SSL("mail.csh.rit.edu", 465, context=context) as server:
            server.login(sender_email, app_password)
            server.sendmail(sender_email, recipient_email, message.as_string())
            print("HTML receipt sent successfully!")
    except Exception as e:
        print(f"Failed to send email: {e}")