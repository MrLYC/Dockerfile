FROM born2data/anaconda:latest

ADD entrypoint.sh /entrypoint.sh

ENV PYTHON_REQUIREMENTS=""

ENTRYPOINT ["/entrypoint.sh"]

CMD $PY3PATH/ipython notebook

