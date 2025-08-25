{ pkgs, ... }:

let
  btop-script = pkgs.writeShellScriptBin "btop-waybar" ''
    #!/usr/bin/env bash
    TITLE="btop-waybar"
    # Find the window with the matching title
    client_id=$(hyprctl clients -j | jq -r ".[] | select(.title == \"$TITLE\") | .address")
    if [[ -n "$client_id" ]]; then
        # Focus the window using its address
        hyprctl dispatch focuswindow address:$client_id
    else
        # Launch a new terminal with the desired title
        kitty --title "$TITLE" -e btop &
    fi
  '';

  get-weather-script = pkgs.writeScriptBin "get-weather" {
    interpreter = "${pkgs.python3}/bin/python";
    runtimeInputs = with pkgs; [ python3 requests ];
  } ''
    #!/usr/bin/env python
    import os
    import json
    import requests
    from datetime import datetime
    # --- Configuration ---
    LOCATION = "Biratnagar, Nepal"
    TEMP_UNIT = os.getenv("WEATHER_TEMPERATURE_UNIT", "c").lower()  # 'c' or 'f'
    TIME_FORMAT = os.getenv("WEATHER_TIME_FORMAT", "12h").lower()  # '12h' or '24h'
    WINDSPEED_UNIT = os.getenv("WEATHER_WINDSPEED_UNIT", "km/h").lower()  # 'km/h' or 'mph'
    SHOW_ICON = os.getenv("WEATHER_SHOW_ICON", "True").lower() in ("true", "1", "t", "y", "yes")
    SHOW_LOCATION = os.getenv("WEATHER_SHOW_LOCATION", "False").lower() in ("true", "1", "t", "y", "yes")
    SHOW_TODAY_DETAILS = os.getenv("WEATHER_SHOW_TODAY_DETAILS", "True").lower() in ("true", "1", "t", "y", "yes")
    FORECAST_DAYS = int(os.getenv("WEATHER_FORECAST_DAYS", "3"))
    WEATHER_CODES = {
        "113": "", "116": "", "119": "", "122": "", "143": "",
        "248": "", "260": "", "176": "", "179": "", "182": "",
        "185": "", "263": "", "266": "", "281": "", "284": "",
        "293": "", "296": "", "299": "", "302": "", "305": "",
        "308": "", "311": "", "314": "", "317": "", "350": "",
        "353": "", "356": "", "359": "", "362": "", "365": "",
        "368": "", "392": "", "200": "", "227": "", "230": "",
        "320": "", "323": "", "326": "", "374": "", "377": "",
        "386": "", "389": "", "329": "", "332": "", "335": "",
        "338": "", "371": "", "395": "",
    }
    def get_weather_data(location):
        try:
            url = f"https://wttr.in/{location}?format=j1"
            headers = {"User-Agent": "Mozilla/5.0"}
            response = requests.get(url, timeout=10, headers=headers)
            response.raise_for_status()
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
        text = format_temperature(current_weather['temp_C'], current_weather['temp_F'])
        if SHOW_ICON:
            text = f'{WEATHER_CODES.get(current_weather["weatherCode"], "❓")} {text}'
        if SHOW_LOCATION:
            location_name = weather["nearest_area"][0]["areaName"][0]["value"]
            country_name = weather["nearest_area"][0]["country"][0]["value"]
            text += f' | {location_name}, {country_name}'
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
  '';
in
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 35;
        modules-left = [ "hyprland/workspaces" "hyprland/window" "mpris" ];
        modules-center = [ "group/center-group" ];
        modules-right = [ "group/right-group" "tray" "custom/logout" ];

        "group/center-group" = {
          orientation = "horizontal";
          modules = [ "clock" "custom/weather" "idle_inhibitor" ];
        };

        "group/right-group" = {
          orientation = "horizontal";
          modules = [
            "pulseaudio"
            "memory"
            "cpu"
            "network"
            "backlight"
            "bluetooth"
            "power-profiles-daemon"
            "battery"
          ];
        };

        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-icons = [ "" ];
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{icon}";
          format-icons = [ "" "" "" "" "" ];
        };

        bluetooth = {
          format = " {status}";
          format-connected = " {device_alias}";
          format-connected-battery = " {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          on-click = "blueman-manager";
        };

        clock = {
          format = "{:%H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          on-click = "gnome-calendar";
        };

        cpu = {
          format = " {usage}%";
          tooltip = true;
          interval = 1;
          on-click = "${btop-script}/bin/btop-waybar";
        };

        disk = {
          format = " {free}";
          interval = 30;
          path = "/";
        };

        "hyprland/window" = {
          format = "{class}:{title}";
          max-length = 20;
          separate-outputs = true;
        };

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            urgent = "";
            focused = "";
            default = "";
          };
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };

        "custom/logout" = {
          format = "󰍃";
          tooltip = false;
          on-click = "wlogout -b 2";
        };

        memory = {
          format = " {used:0.1f}G";
          interval = 1;
          on-click = "${btop-script}/bin/btop-waybar";
        };

        mpris = {
          format = "{player_icon} {title}";
          format-paused = "{status_icon} <i>{title}</i>";
          player-icons = {
            default = "▶";
            mpv = "🎵";
          };
          status-icons = {
            paused = "⏸";
          };
          max-length = 50;
          "on-click-prev" = "playerctl previous";
          "on-click-play" = "playerctl play-pause";
          "on-click-next" = "playerctl next";
        };

        network = {
          "format-wifi" = " ";
          "format-ethernet" = " {ifname}";
          "format-disconnected" = "⚠ Disconnected";
          "tooltip-format" = "{ifname} via {gwaddr} ";
          "on-click" = "nm-connection-editor";
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          "tooltip-format" = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          "format-icons" = {
            default = "";
            performance = "";
            balanced = "";
            "power-saver" = "";
          };
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          "format-muted" = "";
          "format-icons" = {
            headphone = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" ];
          };
          on-click = "pavucontrol";
        };

        tray = {
          "icon-size" = 18;
          spacing = 10;
        };

        "custom/weather" = {
          exec = "${get-weather-script}/bin/get-weather";
          tooltip = true;
          format = "{0}";
          interval = 30;
          "return-type" = "json";
        };
      };
    };
    style = ''
      * {
          border: none;
          font-family: "FiraCode Nerd Font";
          font-size: 14px;
          min-height: 0;
      }
      window#waybar {
          background-color: rgba(40, 40, 40, 0.85);
          color: #ebdbb2;
          transition-property: background-color;
          transition-duration: .5s;
          border-radius: 15px;
          padding: 0 10px;
      }
      #workspaces button {
          padding: 0 10px;
          background-color: transparent;
          color: #ebdbb2;
          border-radius: 0;
          margin: 5px 0;
      }
      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
      }
      #workspaces button.focused {
          background-color: #83a598;
          color: #282828;
      }
      #workspaces button.urgent {
          background-color: #fb4934;
      }
      #workspaces button.active {
          background-color: #ebdbb2;
          color: #282828;
      }
      #window {
          padding: 0 15px;
          margin: 0 10px;
      }
      /* --- Group Styling --- */
      #group/center-group,
      #group/right-group {
          margin: 5px 3px;
          background-color: transparent;
      }
      #group/center-group *,
      #group/right-group * {
          padding: 0 15px;
          color: #ebdbb2;
          background-color: transparent;
          border-radius: 0;
      }
      /* Round the ends of the pills */
      #clock {
          border-top-left-radius: 10px;
          border-bottom-left-radius: 10px;
          margin: 0 10px;
      }
      #custom-weather {
          margin: 0 10px;
      }
      #bluetooth {
          margin: 0 10px;
      }
      #mpris {
          margin: 0 10px;
      }
      #idle_inhibitor{
          border-top-right-radius: 10px;
          border-bottom-right-radius: 10px;
          margin: 0 10px;
      }
      #pulseaudio {
          border-top-left-radius: 10px;
          border-bottom-left-radius: 10px;
          margin: 0 10px;
      }
      #memory {
          margin: 0 10px;
      }
      #power-profiles-daemon {
          margin: 0 10px;
      }
      #cpu {
          margin: 0 10px;
      }
      #disk {
          margin: 0 10px;
      }
      #network {
          margin: 0 10px;
      }
      #custom-logout,
      #backlight {
          margin: 0 10px;
      }
      #battery {
          border-top-right-radius: 10px;
          border-bottom-right-radius: 10px;
          margin: 0 10px;
      }
      #tray {
          background-color: transparent;
          padding: 0 10px;
          margin: 5px 3px;
          border-radius: 10px;
      }
      #custom-power {
          background-color: #fb4934;
          color: #282828;
          padding: 0 10px;
          margin: 5px 3px;
          border-radius: 10px;
      }
      tooltip {
          background-color: rgba(40, 40, 40,0.95);
          color: #ebdbb2;
          border-radius: 10px;
          border: 2px solid #83a598;
          padding: 10px;
      }
      tooltip label {
          color: #ebdbb2;
      }
    '';
  };
}