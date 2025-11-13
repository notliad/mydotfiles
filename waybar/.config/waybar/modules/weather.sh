
#!/bin/bash

# Local (pode ser cidade, coordenadas ou deixar em branco para autodetectar IP)
LOCATION="Juazeiro"
# Cache para evitar request excessivo
CACHEDIR="$HOME/.cache/weather"
CACHEFILE="$CACHEDIR/weather.json"
CACHE_TTL=1800 # 10 minutos

mkdir -p "$CACHEDIR"

# Atualiza o cache se estiver expirado
if [ ! -f "$CACHEFILE" ] || [ $(($(date +%s) - $(stat -c %Y "$CACHEFILE"))) -ge $CACHE_TTL ]; then
    curl -s "https://wttr.in/${LOCATION}?format=j1" -o "$CACHEFILE"
fi

# Lê o JSON e extrai os campos com jq
if [ -f "$CACHEFILE" ]; then
    TEMP=$(jq -r '.current_condition[0].temp_C' "$CACHEFILE")
    FEELS=$(jq -r '.current_condition[0].FeelsLikeC' "$CACHEFILE")
    DESC=$(jq -r '.current_condition[0].weatherDesc[0].value' "$CACHEFILE")
    CITY=$(jq -r '.nearest_area[0].areaName[0].value' "$CACHEFILE")
    HUMIDITY=$(jq -r '.current_condition[0].humidity' "$CACHEFILE")
    WIND=$(jq -r '.current_condition[0].windspeedKmph' "$CACHEFILE")
    WIND_DIR=$(jq -r '.current_condition[0].winddir16Point' "$CACHEFILE")
    MAX=$(jq -r '.weather[0].maxtempC' "$CACHEFILE")
    MIN=$(jq -r '.weather[0].mintempC' "$CACHEFILE")

    # Ícone simples baseado na descrição
    case "$DESC" in
        *rain*|*Rain*) ICON="🌧️" ;;
        *storm*|*Thunder*) ICON="⛈️" ;;
        *cloud*|*Cloud*) ICON="⛅" ;;
        *sun*|*Sun*) ICON="☀️" ;;
        *clear*|*Clear*) ICON="🌙" ;;
        *) ICON="🌡️" ;;
    esac

    # JSON formatado para Waybar
    echo "{\"text\": \"${ICON} ${TEMP}°C\",\"tooltip\": \"${CITY}\n${DESC}\nTemp: ${TEMP}°C (Sensação: ${FEELS}°C)\nMáx: ${MAX}°C | Mín: ${MIN}°C\nUmidade: ${HUMIDITY}%\nVento: ${WIND} km/h ${WIND_DIR}\"}"
else
    echo "{\"text\": \"--°C\", \"tooltip\": \"No data\"}"
fi
