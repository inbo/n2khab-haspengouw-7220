# Sortering van eenheden en punten van habitattype 7220 in Haspengouw

## Inleiding

Met het R-script in deze repository worden objecten geconstrueerd op basis van de [habitatsprings](https://doi.org/10.5281/zenodo.3784149) en de [GRTSmaster_habitats](https://doi.org/10.5281/zenodo.2682323) databronnen.

Het doel is om de populatie-eenheden (en ermee geassocieerde puntlocaties) van habitattype 7220 in Vlaanderen te rangschikken volgens het GRTS-adres in `GRTSmaster_habitats` (meer info via de [`read_GRTSmh()`](https://inbo.github.io/n2khab/reference/read_GRTSmh.html) en [`read_habitatsprings()`](https://inbo.github.io/n2khab/reference/read_habitatsprings.html) functies).
Meer specifiek is deze repository gericht op de populatie-eenheden (en ermee geassocieerde puntlocaties) van habitattype 7220 in de regio Haspengouw.

## Organisatie repository

Het R-script bevindt zich in de root van de repository.
De resulterende bestanden bevinden zich in de map `output`.
Op GitHub worden de GeoJSON bestanden gerendered als een kaart, en de tsv-bestanden als een tabel.
Een overeenkomstig GeoPackage en een shapefile formaat staan op Google Drive in [deze](https://drive.google.com/drive/folders/1mCLEEntD3D0UiFwa1epRl72XrH_RY_l9?usp=sharing) map.

## Outputbestanden

De volgende datasets zijn gecreëerd als GeoJSON (RFC7946), GeoPackage (met 2 layers: eenheden; punten), shapefile en als tsv (attributen + xy-coördinaten in CRS EPSG:31370):

- alle **populatie-eenheden** (units) van 7220 in Vlaanderen, met GRTS-rangschikking;
- idem, beperkt tot de regio Haspengouw;
- alle met de eenheden geassocieerde **punten** (points) met 7220 in Vlaanderen, met GRTS-rangschikking;
- idem, beperkt tot de regio Haspengouw.

In alle gevallen zijn dezelfde extra kolommen toegevoegd met betrekking tot de GRTS-rangschikking van **populatie-eenheden** van 7220, inclusief de kolommen specifiek voor Haspengouw.
