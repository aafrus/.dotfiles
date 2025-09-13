# ---[ Security Aliases ]--------------------------------
# AV Tools
alias checkrootkits="sudo rkhunter --update; sudo rkhunter --propupd; sudo rkhunter --sk --check"
alias checkvirus="clamscan --recursive=yes --infected /home"
alias updateantivirus="sudo freshclam"

# System Monitoring
alias listports="sudo netstat -tulnp"
alias checkauth="sudo tail -n 20 /var/log/auth.log"