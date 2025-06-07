FROM ubuntu:20.04
RUN apt-get update && apt-get install -y curl libxml2-utils cron
COPY scripts /scripts
RUN chmod +x /scripts/*.sh
RUN echo "*/5 * * * * /scripts/fetch_parking.sh && /scripts/generate_html.sh" > /etc/cron.d/parking-cron \
    && chmod 0644 /etc/cron.d/parking-cron \
    && crontab /etc/cron.d/parking-cron
CMD cron -f
