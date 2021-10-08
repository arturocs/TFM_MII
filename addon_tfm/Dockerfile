FROM python:3.9-slim
ENV LANG C.UTF-8

# Copy data for add-on
COPY script.py /
#COPY apptfm-76e81-firebase-adminsdk-7wjsz-3dd51ba066.json /
COPY requirements.txt /

# Install requirements for add-on
RUN pip install -r requirements.txt

CMD [ "python3", "script.py" ] 

