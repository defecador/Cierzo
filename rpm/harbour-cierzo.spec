Name:       harbour-cierzo
Summary:    Surface observation and forecast
Version:    0.1.3
Release:    1
License:    GPLv3+
URL:        https://github.com/defecador/Cierzo
Source0:    %{name}-%{version}.tar.bz2

Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   libsailfishapp-launcher
# QtPositioning, for "Use my position" on the Places page.
# Jolla Harbour does not allow this import: to submit to the Jolla Store,
# drop this line and the PositionSource block in qml/pages/PlacesPage.qml.
Requires:   qt5-qtdeclarative-import-positioning
Requires:   qt5-qtdeclarative-import-localstorageplugin

BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

BuildArch:  noarch

%description
A weather reader in the shape of a station report: the current
observation in synoptic units, a temperature curve for the hours
ahead, and seven days on one shared scale. Forecasts come from a
national meteorological service's own model, chosen in Settings.
The last reading is kept on the phone for when there is no signal.

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5
make %{?_smp_mflags}

%install
%qmake5_install
desktop-file-install --delete-original \
    --dir %{buildroot}%{_datadir}/applications \
    %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png

%changelog
* Fri Sep 11 2026 defecador <57116457+defecador@users.noreply.github.com> 0.1.3-1
- Declare a sandbox profile asking for Internet and Location only. With
  no declaration, Sailfish applied its default profile of twelve
  permissions, including camera, microphone, Bluetooth, NFC and the
  user's files, none of which Cierzo uses.

* Wed Sep 09 2026 defecador <57116457+defecador@users.noreply.github.com> 0.1.2-1
- Hourly chart: the warmest and coldest hour labels never drew, because
  Qt's Canvas rejects a numeric font weight. Keep labels inside the plot
  and stop the "now" caption sitting on its own marker.

* Wed Sep 09 2026 defecador <57116457+defecador@users.noreply.github.com> 0.1.1-1
- Name a GPS position properly: Open-Meteo has no reverse geocoding
  endpoint, so fixes were saved as "Here". Uses a reverse geocoder that
  exists.

* Wed Sep 09 2026 Guillermo <guillermo@localhost> 0.1.0-1
- First build: current observation, 48-hour curve, seven-day scale,
  selectable forecast model, saved places, offline last reading.
