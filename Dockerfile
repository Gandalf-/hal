FROM ubuntu
RUN apt -q update && apt -y install bc netcat tmux curl make
ADD . /
RUN make install
EXPOSE 2095
# tmux new-session -d -n 'hal' -c '/opt/local/hal/demo/' 'bash web_server.sh
# CMD ["tmux", "new-session", "-n", "hal", "-c", "/demo", "bash", "web_server.sh"]
WORKDIR /demo
CMD ["bash", "web_server.sh"]
