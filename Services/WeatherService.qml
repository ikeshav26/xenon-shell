import QtQuick
import Quickshell
pragma Singleton

Item {
    id: root

    property string temperature: "--"
    property string conditionText: "Unknown"
    property string city: "Locating..."
    property string icon: ""
    property bool isDay: true
    property string humidity: "--%"
    property string wind: "-- km/h"
    property string pressure: "-- hPa"
    property string uvIndex: "--"
    property string sunrise: "--:--"
    property string sunset: "--:--"
    property var hourlyForecast: []
    property var forecastModel: []
    property int refreshInterval: 1.8e+06
    property var _weatherCodes: {
        "0": {
            "day": "",
            "night": "",
            "desc": "Clear sky"
        },
        "1": {
            "day": "",
            "night": "",
            "desc": "Mainly clear"
        },
        "2": {
            "day": "",
            "night": "",
            "desc": "Partly cloudy"
        },
        "3": {
            "day": "",
            "night": "",
            "desc": "Overcast"
        },
        "45": {
            "day": "",
            "night": "",
            "desc": "Fog"
        },
        "48": {
            "day": "",
            "night": "",
            "desc": "Depositing rime fog"
        },
        "51": {
            "day": "",
            "night": "",
            "desc": "Light drizzle"
        },
        "53": {
            "day": "",
            "night": "",
            "desc": "Moderate drizzle"
        },
        "55": {
            "day": "",
            "night": "",
            "desc": "Dense drizzle"
        },
        "61": {
            "day": "",
            "night": "",
            "desc": "Slight rain"
        },
        "63": {
            "day": "",
            "night": "",
            "desc": "Moderate rain"
        },
        "65": {
            "day": "",
            "night": "",
            "desc": "Heavy rain"
        },
        "71": {
            "day": "",
            "night": "",
            "desc": "Slight snow"
        },
        "73": {
            "day": "",
            "night": "",
            "desc": "Moderate snow"
        },
        "75": {
            "day": "",
            "night": "",
            "desc": "Heavy snow"
        },
        "77": {
            "day": "",
            "night": "",
            "desc": "Snow grains"
        },
        "80": {
            "day": "",
            "night": "",
            "desc": "Slight rain showers"
        },
        "81": {
            "day": "",
            "night": "",
            "desc": "Moderate rain showers"
        },
        "82": {
            "day": "",
            "night": "",
            "desc": "Violent rain showers"
        },
        "85": {
            "day": "",
            "night": "",
            "desc": "Slight snow showers"
        },
        "86": {
            "day": "",
            "night": "",
            "desc": "Heavy snow showers"
        },
        "95": {
            "day": "",
            "night": "",
            "desc": "Thunderstorm"
        },
        "96": {
            "day": "",
            "night": "",
            "desc": "Thunderstorm with hail"
        },
        "99": {
            "day": "",
            "night": "",
            "desc": "Thunderstorm with heavy hail"
        }
    }

    function formatTime(isoString) {
        if (!isoString)
            return "--:--";

        var date = new Date(isoString);
        return date.toLocaleTimeString(Qt.locale(), Locale.ShortFormat).replace(/:\d\d /, " ");
    }

    function getDayName(dateString) {
        var date = new Date(dateString);
        return date.toLocaleDateString(Qt.locale(), "ddd");
    }

    function fetchLocation() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (response.city)
                            root.city = response.city;

                        fetchWeather(response.lat, response.lon);
                    } catch (e) {
                        console.warn("[Weather] Location JSON parse error", e);
                    }
                }
            }
        };
        xhr.open("GET", "http://ip-api.com/json");
        xhr.send();
    }

    function fetchWeather(lat, lon) {
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&current=temperature_2m,is_day,weather_code,relative_humidity_2m,wind_speed_10m,surface_pressure" + "&hourly=temperature_2m" + "&daily=weather_code,temperature_2m_max,temperature_2m_min,uv_index_max,sunrise,sunset" + "&timezone=auto&temperature_unit=celsius&wind_speed_unit=kmh&forecast_days=7";
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        var current = response.current;
                        root.temperature = Math.round(current.temperature_2m) + "°";
                        root.isDay = current.is_day === 1;
                        root.humidity = current.relative_humidity_2m + "%";
                        root.wind = current.wind_speed_10m + " km/h";
                        root.pressure = Math.round(current.surface_pressure) + " hPa";
                        var code = current.weather_code;
                        var info = root._weatherCodes[code] || {
                            "day": "",
                            "night": "",
                            "desc": "Unknown"
                        };
                        root.icon = root.isDay ? info.day : info.night;
                        root.conditionText = info.desc;
                        var daily = response.daily;
                        if (daily) {
                            if (daily.uv_index_max && daily.uv_index_max.length > 0)
                                root.uvIndex = daily.uv_index_max[0].toString();

                            if (daily.sunrise && daily.sunrise.length > 0)
                                root.sunrise = formatTime(daily.sunrise[0]);

                            if (daily.sunset && daily.sunset.length > 0)
                                root.sunset = formatTime(daily.sunset[0]);

                        }
                        var hourly = response.hourly;
                        if (hourly && hourly.temperature_2m) {
                            var currentHourIndex = new Date().getHours();
                            var slice = hourly.temperature_2m.slice(currentHourIndex, currentHourIndex + 24);
                            root.hourlyForecast = slice;
                        }
                        var newForecast = [];
                        for (var i = 1; i < 6; i++) {
                            if (!daily.time[i])
                                break;

                            var fCode = daily.weather_code[i];
                            var fInfo = root._weatherCodes[fCode] || {
                                "day": "",
                                "desc": "Unknown"
                            };
                            newForecast.push({
                                "day": getDayName(daily.time[i]),
                                "icon": fInfo.day,
                                "max": Math.round(daily.temperature_2m_max[i]) + "°",
                                "min": Math.round(daily.temperature_2m_min[i]) + "°",
                                "condition": fInfo.desc
                            });
                        }
                        root.forecastModel = newForecast;
                    } catch (e) {
                        console.warn("[Weather] Weather JSON parse error", e);
                    }
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }

    Timer {
        interval: root.refreshInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.fetchLocation()
    }

}
