{% set MINOR_VERSION = '0.11' %}
{% set VERSION = '0.11.6' %}

download_fluentbit:
  archive.extracted:
    - name: /home/vagrant
    - source: http://fluentbit.io/releases/{{ MINOR_VERSION }}/fluent-bit-{{ VERSION }}.tar.gz
    - skip_verify: True
    - user: vagrant

construct_build_dir:
  file.directory:
    - name: /home/vagrant/fluent-bit-{{ VERSION }}/build
    - user: vagrant

run_cmake:
  cmd.run:
    - name: cmake ../
    - cwd: /home/vagrant/fluent-bit-{{ VERSION }}/build
    - user: vagrant

make_fluentbit:
  cmd.run:
    - name: make
    - cwd: /home/vagrant/fluent-bit-{{ VERSION }}/build
    - user: vagrant

create_install_dir:
  file.directory:
    - name: /tmp/fluentbit
    - user: vagrant

install_fluentbit:
  cmd.run:
    - name: make install DESTDIR=/tmp/fluentbit
    - cwd: /home/vagrant/fluent-bit-{{ VERSION }}/build

copy_upstart_service:
  file.managed:
    - name: /tmp/fluentbit/etc/init/fluent-bit.conf
    - source: salt://files/fluentbit/etc/init/fluent-bit.conf
    - makedirs: True
    - user: vagrant

copy_systemd_service:
  file.managed:
    - name: /tmp/fluentbit/lib/systemd/system/fluent-bit.service
    - source: salt://files/fluentbit/lib/systemd/system/fluent-bit.service
    - makedirs: True
    - user: vagrant

package_fluentbit:
  cmd.run:
    - name: fpm -s dir -t deb -n "fluentbit" -v {{ VERSION }} -C /tmp/fluentbit
    - creates: /vagrant/fluentbit_{{ VERSION }}_amd64.deb
    - cwd: /vagrant
    - user: vagrant
    - require:
      - gem: fpm