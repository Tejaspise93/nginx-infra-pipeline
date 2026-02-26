[nginx_servers]
%{ for ip in servers_ips ~}
${ip}
%{ endfor ~}