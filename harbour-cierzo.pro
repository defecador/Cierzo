TARGET = harbour-cierzo

CONFIG += sailfishapp_qml

DISTFILES += \
    qml/harbour-cierzo.qml \
    qml/js/wx.js \
    qml/components/WeatherIcon.qml \
    qml/components/WindRose.qml \
    qml/components/HourlyChart.qml \
    qml/components/Reading.qml \
    qml/components/DayRow.qml \
    qml/cover/CoverPage.qml \
    qml/pages/ForecastPage.qml \
    qml/pages/DayPage.qml \
    qml/pages/PlacesPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/AboutPage.qml \
    rpm/harbour-cierzo.spec \
    harbour-cierzo.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172
