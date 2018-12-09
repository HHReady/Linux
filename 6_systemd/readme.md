________________________
Systemd
1. �������� ������, ������� ����� ��� � 30 ������ ���������� ��� �� ������� ������� ��������� �����. ���� � ����� ������ ���������� � /etc/sysconfig
2. �� epel ���������� spawn-fcgi � ���������� init-������ �� unit-����. ��� ������� ������ ��� �� ����������.
3. ��������� ����-���� apache httpd ������������ ��������� ��������� ��������� ������� � ������� ���������
________________________

��� ���������� ������ ������� ��������������� ������ https://www.freedesktop.org/software/systemd/man/systemd.service.html

Options

KillMode=

    Specifies how processes of this unit shall be killed. One of control-group, process, mixed, none.

    If set to control-group, all remaining processes in the control group of this unit will be killed on unit stop (for services: after the stop command is executed, as configured with ExecStop=). If set to process, only the main process itself is killed. If set to mixed, the SIGTERM signal (see below) is sent to the main process while the subsequent SIGKILL signal (see below) is sent to all remaining processes of the unit's control group. If set to none, no process is killed. In this case, only the stop command will be executed on unit stop, but no process be killed otherwise. Processes remaining alive after stop are left in their control group and the control group continues to exist after stop unless it is empty.

    Processes will first be terminated via SIGTERM (unless the signal to send is changed via KillSignal=). Optionally, this is immediately followed by a SIGHUP (if enabled with SendSIGHUP=). If then, after a delay (configured via the TimeoutStopSec= option), processes still remain, the termination request is repeated with the SIGKILL signal (unless this is disabled via the SendSIGKILL= option). See kill(2) for more information.

    Defaults to control-group.
	
KillSignal=

    Specifies which signal to use when killing a service. This controls the signal that is sent as first step of shutting down a unit (see above), and is usually followed by SIGKILL (see above and below). For a list of valid signals, see signal(7). Defaults to SIGTERM.

    Note that, right after sending the signal specified in this setting, systemd will always send SIGCONT, to ensure that even suspended tasks can be terminated cleanly.
	
	Signal     Value     Action   Comment
       ----------------------------------------------------------------------
       SIGHUP        1       Term    Hangup detected on controlling terminal
                                     or death of controlling process
       SIGINT        2       Term    Interrupt from keyboard
       SIGQUIT       3       Core    Quit from keyboard
       SIGILL        4       Core    Illegal Instruction
       SIGABRT       6       Core    Abort signal from abort(3)
       SIGFPE        8       Core    Floating-point exception
       SIGKILL       9       Term    Kill signal
       SIGSEGV      11       Core    Invalid memory reference
       SIGPIPE      13       Term    Broken pipe: write to pipe with no
                                     readers; see pipe(7)
       SIGALRM      14       Term    Timer signal from alarm(2)
       SIGTERM      15       Term    Termination signal
       SIGUSR1   30,10,16    Term    User-defined signal 1
       SIGUSR2   31,12,17    Term    User-defined signal 2
       SIGCHLD   20,17,18    Ign     Child stopped or terminated
       SIGCONT   19,18,25    Cont    Continue if stopped
       SIGSTOP   17,19,23    Stop    Stop process
       SIGTSTP   18,20,24    Stop    Stop typed at terminal
       SIGTTIN   21,21,26    Stop    Terminal input for background process
       SIGTTOU   22,22,27    Stop    Terminal output for background process
	   
	 _____________________
	 
	 https://wiki.archlinux.org/index.php/Systemd/Timers_(%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)
	 
	 timer 
	 
	 ������� systemd - ��� ����� ������ � ��������� .timer. ���, ��� � ������ ����� �������� ������, ����������� �� ������ � ���� �� ����, �� �������� � ���� ������ [Timer]. �� ����������, ��� � ����� ������ �����������. ���������� ��� ���� ��������:

    ������� ��������� ������� (����� ��������� ��� ��������� ����) ����������� � ����������� �� ������� ��������� (��� cronjobs). ��� ����������� ����� �������� ������������ ����� OnCalendar=.
    ���������� ������� ������������ ����� ������������� ���������� ������� �� ��������� � ��� ��� ���� ��������� �����. ��� �� ���������, ���� ��������� ��������� � ������ �������� ��� ��������. ���� ��������� ��������� ���������� ��������, �� ��� ��� ����� ���: OnTypeSec=. ������ ���������� ������� �������� � ���� OnBootSec � OnActiveSec.
	
	������� �� 
	[Unit]
	
	[Timer]
	��� ������� 
	OnCalendar= ��� OnTypeSec=
	
	������� ����� .timer �������� ��������������� ���� .service (��������, foo.timer � foo.service)
	
	��� ����, ����� ������������ ���� timer, �������� � ��������� ���, ��� ����� ������ ����
	
	ystemctl list-timers  # �������� ���� ��������
	
	systemctl list-timers --all # � �� �������� ���� ���������
	
	______
	���� ������ ��������������������, �� ����� ������ �������� ��������������� ������ stamp-* � /var/lib/systemd/timers (��� ~/.local/share/systemd/). ��� �����, � ������� �������, ������� �������� ��������� �����, ����� ������ ��� �������. ���� ������ ����� �����������, �� ��� ����� ����������� ��� ��������� ������� ���������������� �������.
	______
	
	��������� ����� .timer

����� ������������ systemd-run ��� �������� ��������� ������ .timer. �� ����, ����� ��������� ������ ������������ ������� � ����� �����, �� ��� ����� �������. ��������, ��������� ������� ������� ���� ����� 30 ������:

# systemd-run --on-active=30 /bin/touch /tmp/foo
