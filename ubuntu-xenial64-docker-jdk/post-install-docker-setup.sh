#!/usr/bin/env bash

# docker daemon start script
[ $(id -u) = 0 ] || { echo 'must be root' ; exit 1; }

__set_docker_opts () {

  # systemd configuration file
  if [ -f "/lib/systemd/system/docker.service" ]; then
    echo "append socket in /lib/systemd/system/docker.service"
    __append_docker_opts_in_file "/lib/systemd/system/docker.service"
    [ $? -ne 0 ] && return 1;
  fi

  # docker default configuration file
  if [ -f "/etc/default/docker" ]; then
    echo "set DOCKER_OPTS in /etc/default/docker"
    __set_docker_opts_in_file "/etc/default/docker"
    [ $? -ne 0 ] && return 1;
  fi

  # upstart configuration file
  if [ -f "/etc/init/docker.conf" ]; then
    echo "set DOCKER_OPTS in /etc/init/docker.conf"
    __set_docker_opts_in_file "/etc/init/docker.conf"
    [ $? -ne 0 ] && return 1;
  fi

  # init.d script
  if [ -f "/etc/init.d/docker" ]; then
    echo "set DOCKER_OPTS in /etc/init.d/docker"
    __set_docker_opts_in_file "/etc/init.d/docker"
    [ $? -ne 0 ] && return 1;
  fi

  return 0;
}

__set_docker_opts_in_file () {
  grep "\-H 0.0.0.0:2376" $1 1>/dev/null
  if [ $? -eq 0 ];
  then
    echo "-H 0.0.0.0:2376 already defined in DOCKER_OPTS.";
    return 0;
  fi

  sed -i 's/^[^[:space:]]*DOCKER_OPTS=$/DOCKER_OPTS=\"\"/' $1 && sed -i 's/^[^[:space:]]*DOCKER_OPTS=\"/DOCKER_OPTS=\"-H 0.0.0.0:2376 /' $1
  return $?
}

__append_docker_opts_in_file () {
  grep "\-H 0.0.0.0:2376" $1 1>/dev/null
  if [ $? -eq 0 ];
  then
    echo "-H 0.0.0.0:2376 already added in the ExecStart.";
    return 0;
  fi

  sed -i 's/^ExecStart=\/usr\/bin\/dockerd/ExecStart=\/usr\/bin\/dockerd -H 0.0.0.0:2376 /' $1
  return $?
}

if ! __set_docker_opts; then
  echo "failed to set DOCKER_OPTS."
fi
