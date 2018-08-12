import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import os
import base64

# python email

fromaddr = "gfeng22@gmail.com"
toaddr = "gfeng22@outlook.com"

msg = MIMEMultipart()
msg['From'] = fromaddr
msg['To'] = toaddr
msg['Subject'] = "DOW 30 YTD Return & Plot - "
 
body = "Please view dow30indexstats.csv for details - "
msg.attach(MIMEText(body, 'plain'))

filename = "dow30ytdreturn.csv"
attachment = open("csv/dow30ytdreturn.csv", "rb")
part = MIMEBase('application', 'octet-stream')
part.set_payload((attachment).read())
encoders.encode_base64(part)
part.add_header('Content-Disposition', "attachment; filename= %s" % filename)
msg.attach(part)

filename = "dow30ytdplot.png"
attachment = open("plot/dow30ytdplot.png", "rb")
part = MIMEBase('application', 'octet-stream')
part.set_payload((attachment).read())
encoders.encode_base64(part)
part.add_header('Content-Disposition', "attachment; filename= %s" % filename)
msg.attach(part)

filename = "dow30indexstats.csv"
attachment = open("csv/dow30indexstats.csv", "rb")
part = MIMEBase('application', 'octet-stream')
part.set_payload((attachment).read())
encoders.encode_base64(part)
part.add_header('Content-Disposition', "attachment; filename= %s" % filename)
msg.attach(part)


server = smtplib.SMTP('smtp.gmail.com', 587)
server.starttls()
server.login(fromaddr, "Br000klyn")
text = msg.as_string()
server.sendmail(fromaddr, toaddr, text)
server.quit()

print('email has been sent to gfeng22@outlook.com')
