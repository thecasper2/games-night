FROM rocker/shiny-verse:3.6.1

# Install required files
RUN apt-get update && apt-get install -y \
	nano \
	mysql-server

# Download and install required R libraries
RUN R -e "install.packages(c('data.table'))"
RUN R -e "install.packages(c('flexdashboard'))"
RUN R -e "install.packages(c('ggplot2'))"
RUN R -e "install.packages(c('RMySQL'))"

# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /srv/shiny-server/

CMD ["/usr/bin/shiny-server.sh"] 