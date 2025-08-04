#!/usr/bin/env python

import os
import json
import requests
from datetime import datetime

# --- Configuration ---
LOCATION = "Biratnagar,Nepal"
TEMP_UNIT = os.getenv("WEATHER_TEMPERATURE_UNIT", "c").lower()  # 'c' or 'f'
TIME_FORMAT = os.getenv("WEATHER_TIME_FORMAT", "12h").lower()  # '12h' or '24h'
WINDSPEED_UNIT = os.getenv("WEATHER_WINDSPEED_UNIT", "km/h").lower()  # 'km/h' or 'mph'
SHOW_ICON = os.getenv("WEATHER_SHOW_ICON", "True").lower() in ("true", "1", "t", "y", "yes")
SHOW_LOCATION = os.getenv("WEATHER_SHOW_LOCATION", "False").lower() in ("true", "1", "t", "y", "yes")
SHOW_TODAY_DETAILS = os.getenv("WEATHER_SHOW_TODAY_DETAILS", "True").lower() in ("true", "1", "t", "y", "yes")
FORECAST_DAYS = int(os.getenv("WEATHER_FORECAST_DAYS", "3"))

WEATHER_CODES = {
    "113": "",  # Clear (nf-weather-day-sunny)
    "116": "",  # Partly cloudy (nf-weather-day-cloudy)
    "119": "",  # Cloudy (nf-weather-cloud)
    "122": "",  # Overcast
    "143": "",  # Mist (nf-weather-fog)
    "248": "",  # Fog
    "260": "",  # Freezing fog

    "176": "",  # Patchy rain possible (nf-weather-showers)
    "179": "",  # Patchy snow possible (nf-weather-snow)
    "182": "",  # Patchy sleet possible
    "185": "",  # Freezing drizzle
    "263": "", "266": "", "281": "", "284": "",
    "293": "", "296": "", "299": "", "302": "",
    "305": "", "308": "", "311": "", "314": "",
    "317": "", "350": "", "353": "", "356": "",
    "359": "", "362": "", "365": "", "368": "",
    "392": "",

    "200": "",  # Thunderstorm (nf-weather-storm-showers)
    "227": "",  # Blowing snow
    "230": "",  # Blizzard
    "320": "", "323": "", "326": "", "374": "",
    "377": "", "386": "", "389": "",

    "329": "",  # Light snow
    "332": "",  # Moderate snow
    "335": "",  # Heavy snow
    "338": "",  # Very heavy snow
    "371": "", "395": "",
}

def get_weather_data(location):
    try:
        url = f"https://wttr.in/{location}?format=j1"
        headers = {"User-Agent": "Mozilla/5.0"}
        response = requests.get(url, timeout=10, headers=headers)
        response.raise_for_status()  # Raise an exception for bad status codes
        return response.json()
    except (requests.exceptions.RequestException, json.JSONDecodeError) as e:
        return {"error": str(e)}

def format_temperature(temp_c, temp_f):
    return f'{temp_c}°C' if TEMP_UNIT == "c" else f'{temp_f}°F'

def format_wind_speed(kmph, mph):
    return f'{kmph}Km/h' if WINDSPEED_UNIT == "km/h" else f'{mph}Mph'

def format_time(time_str):
    if TIME_FORMAT == "24h":
        return datetime.strptime(time_str, "%I:%M %p").strftime("%H:%M")
    return time_str

def main():
    weather = get_weather_data(LOCATION)

    if "error" in weather:
        print(json.dumps({"text": "⚠️", "tooltip": weather["error"]}))
        return

    current_weather = weather["current_condition"][0]
    today = weather['weather'][0]

    # --- Waybar Text ---
    text = format_temperature(current_weather['temp_C'], current_weather['temp_F'])
    if SHOW_ICON:
        text = f'{WEATHER_CODES.get(current_weather["weatherCode"], "❓")} {text}'
    if SHOW_LOCATION:
        location_name = weather["nearest_area"][0]["areaName"][0]["value"]
        country_name = weather["nearest_area"][0]["country"][0]["value"]
        text += f' | {location_name}, {country_name}'

    # --- Waybar Tooltip ---
    tooltip = ""
    if SHOW_TODAY_DETAILS:
        location_name = weather["nearest_area"][0]["areaName"][0]["value"]
        country_name = weather["nearest_area"][0]["country"][0]["value"]
        feels_like = format_temperature(current_weather['FeelsLikeC'], current_weather['FeelsLikeF'])
        wind_speed = format_wind_speed(current_weather['windspeedKmph'], current_weather['windspeedMiles'])
        sunrise = format_time(today['astronomy'][0]['sunrise'])
        sunset = format_time(today['astronomy'][0]['sunset'])

        tooltip += f'<b>{current_weather["weatherDesc"][0]["value"]} {text}</b>\n'
        tooltip += f'Feels like: {feels_like}\n'
        tooltip += f'Location: {location_name}, {country_name}\n'
        tooltip += f'Wind: {wind_speed}\n'
        tooltip += f'Humidity: {current_weather["humidity"]}%\n'
        tooltip += f' {sunrise}  {sunset}\n'

    for i in range(FORECAST_DAYS):
        day = weather["weather"][i]
        day_name = "Today" if i == 0 else "Tomorrow" if i == 1 else day['date']
        max_temp = format_temperature(day['maxtempC'], day['maxtempF'])
        min_temp = format_temperature(day['mintempC'], day['mintempF'])
        tooltip += f'\n<b>{day_name}</b>\n'
        tooltip += f'⬆️ {max_temp} ⬇️ {min_temp}\n'

        for hour in day["hourly"]:
            if i == 0 and int(hour["time"]) < datetime.now().hour * 100:
                continue
            hour_time = format_time(f'{int(hour["time"])//100:02d}:{int(hour["time"])%100:02d}')
            hour_temp = format_temperature(hour['tempC'], hour['tempF'])
            weather_icon = WEATHER_CODES.get(hour["weatherCode"], "❓")
            tooltip += f'{hour_time} {weather_icon} {hour_temp} {hour["weatherDesc"][0]["value"]}\n'

    print(json.dumps({"text": text, "tooltip": tooltip.strip()}))

if __name__ == "__main__":
    main()
