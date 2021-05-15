let
  cred = import <secrets/ham/nextcloud-calendar>;
in
{
  services.home-assistant.config.calendar =
  [
    {
      platform = "caldav";
      inherit (cred) username password;
      url = "https://o.euer.krebsco.de/remote.php/dav";
      # make calendars "all-day" before uploading:
      #   sed -i -e 's/^\(DTSTART;.*\)T......\r$/\1\r/' -e #   's/^\(DTEND;.*\)T......\r$/\1\r/' abfall.ical
      custom_calendars = [
        {
          name = "Gelbersack";
          calendar = "Abfall";
          search = "Gelber Sack.*";
        }
        {
          name = "Biomuell";
          calendar = "Abfall";
          search = "Bio.*";
        }
        {
          name = "Restmuell";
          calendar = "Abfall";
          search = "Rest.*";
        }
        {
          name = "Papiermuell";
          calendar = "Abfall";
          search = "Altpapier.*";
        }
        {
          name = "Kehrwoche";
          calendar = "Kehrwoche";
          search = ".*";
        }
      ];
    }

  ];
}
