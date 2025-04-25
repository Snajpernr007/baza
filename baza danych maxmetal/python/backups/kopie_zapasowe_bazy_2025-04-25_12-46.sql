SET FOREIGN_KEY_CHECKS = 0;

-- Struktura tabeli `uprawnienia`
CREATE TABLE `uprawnienia` (
  `id_uprawnienia` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id_uprawnienia`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `uzytkownicy`
CREATE TABLE `uzytkownicy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` text DEFAULT NULL,
  `haslo` text NOT NULL,
  `id_uprawnienia` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_uzytkownicy_uprawnienia` (`id_uprawnienia`),
  CONSTRAINT `fk_uzytkownicy_uprawnienia` FOREIGN KEY (`id_uprawnienia`) REFERENCES `uprawnienia` (`id_uprawnienia`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `dostawcy`
CREATE TABLE `dostawcy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nazwa` (`nazwa`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `szablon`
CREATE TABLE `szablon` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  `rodzaj` varchar(255) NOT NULL,
  `grubosc_i_oznaczenie_ocynku` varchar(255) NOT NULL,
  `grubosc` decimal(10,2) NOT NULL,
  `szerokosc` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nazwa` (`nazwa`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `lokalizacja`
CREATE TABLE `lokalizacja` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `dlugosci`
CREATE TABLE `dlugosci` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nazwa` (`nazwa`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `tasma`
CREATE TABLE `tasma` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_z_etykiety_na_kregu` date NOT NULL,
  `grubosc` decimal(10,2) NOT NULL,
  `szerokosc` decimal(10,2) NOT NULL,
  `waga_kregu` decimal(10,2) NOT NULL,
  `waga_kregu_na_stanie` decimal(10,2) NOT NULL,
  `nr_etykieta_paletowa` varchar(255) NOT NULL,
  `nr_z_etykiety_na_kregu` varchar(255) NOT NULL,
  `lokalizacja_id` int(11) DEFAULT NULL,
  `nr_faktury_dostawcy` varchar(255) NOT NULL,
  `data_dostawy` date NOT NULL,
  `pracownik_id` int(11) DEFAULT NULL,
  `dostawca_id` int(11) NOT NULL,
  `szablon_id` int(11) NOT NULL,
  `Data_do_usuwania` date NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_tasma_pracownik` (`pracownik_id`),
  KEY `fk_tasma_dostawca` (`dostawca_id`),
  KEY `fk_tasma_szablon` (`szablon_id`),
  KEY `fk_tasma_lokalizacja` (`lokalizacja_id`),
  CONSTRAINT `fk_tasma_dostawca` FOREIGN KEY (`dostawca_id`) REFERENCES `dostawcy` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tasma_lokalizacja` FOREIGN KEY (`lokalizacja_id`) REFERENCES `lokalizacja` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tasma_pracownik` FOREIGN KEY (`pracownik_id`) REFERENCES `uzytkownicy` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_tasma_szablon` FOREIGN KEY (`szablon_id`) REFERENCES `szablon` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `profil`
CREATE TABLE `profil` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_tasmy` int(11) DEFAULT NULL,
  `data_produkcji` date DEFAULT NULL,
  `godz_min_rozpoczecia` time DEFAULT NULL,
  `godz_min_zakonczenia` time DEFAULT NULL,
  `zwrot_na_magazyn_kg` decimal(10,2) DEFAULT NULL,
  `id_szablon_profile` int(11) NOT NULL,
  `nazwa_klienta_nr_zlecenia_PRODIO` varchar(100) DEFAULT NULL,
  `ilosc` int(11) DEFAULT NULL,
  `ilosc_na_stanie` int(11) DEFAULT NULL,
  `id_dlugosci` int(11) DEFAULT NULL,
  `id_pracownika` int(11) DEFAULT NULL,
  `imie_nazwisko_pracownika` varchar(50) NOT NULL,
  `Data_do_usuwania` date DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `id_tasmy` (`id_tasmy`),
  KEY `id_pracownika` (`id_pracownika`),
  KEY `profil_ibfk_3` (`id_dlugosci`),
  KEY `profil_ibfk_4` (`id_szablon_profile`),
  CONSTRAINT `profil_ibfk_1` FOREIGN KEY (`id_tasmy`) REFERENCES `tasma` (`id`) ON DELETE CASCADE,
  CONSTRAINT `profil_ibfk_2` FOREIGN KEY (`id_pracownika`) REFERENCES `uzytkownicy` (`id`) ON DELETE CASCADE,
  CONSTRAINT `profil_ibfk_3` FOREIGN KEY (`id_dlugosci`) REFERENCES `dlugosci` (`id`) ON DELETE CASCADE,
  CONSTRAINT `profil_ibfk_4` FOREIGN KEY (`id_szablon_profile`) REFERENCES `szablon_profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dane z tabeli `uprawnienia`
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES ('1', 'Administrator');
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES ('2', 'Zaopatrzeniowiec ');
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES ('3', 'Pracownik');

-- Dane z tabeli `uzytkownicy`
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES ('1', 'Administrator', 'scrypt:32768:8:1$Hj9SEP8K0oUaPATE$2332f998cad623e8624ec649b50fc69216cad1d0671f4eb9f9a74349e130a156a9db10a084805ef189007bcd31a22c31e072d3ced59e37118e3077bed8d7bcc7', '1');
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES ('19', 'Maciej M', 'scrypt:32768:8:1$tSm1MtjsRtHuPUfo$ec2f18a3fd2792023276416269ceca571b78aa5726e5a1c209dd1c3eae083a66748c817e83c2dcc053b345a6df5d4ede44a435d8e1a6565e3d97f5eee0d76292', '1');
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES ('20', 'p.lewandowski', 'scrypt:32768:8:1$S2pdLmDW850hDG1D$afb0452ef6278436539b4889d7a776c44d163598e879261a2c2c48a6d0734c46045f6098f9967b4d8b3e8fbbe35dc7fac510f3c1c95a90afb7d88b5dd0646573', '2');
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES ('21', 'Profilowanie', 'scrypt:32768:8:1$JAO1lLrDVoOVmtWg$48aee5a880be2ab588e65efdfb281afbc1dbbc518051ffa227ee9d38f11e20f6085c069aafdf63fb1d100aaaee923ed0deb43ebc4c98aaf152de8a309410ce54', '3');

-- Dane z tabeli `dostawcy`
INSERT INTO `dostawcy` (id, nazwa) VALUES ('9', 'ArcelorMittal Sp. z o.o.');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('12', 'KS Service Center B.V');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('11', 'Marcegaglia');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('6', 'RBB-STAL');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('14', 'Salzgitter GmbH');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('7', 'Serwistal');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('13', 'SSAB');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('8', 'STEL-MARK');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('10', 'Tesko Steel');

-- Dane z tabeli `szablon`
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('11', 'DX51D Z100 38.6x0.5', 'DX51D', 'Z100', '0.50', '38.60');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('12', 'S250GD Z275 93.3x1.5', 'S250GD', 'Z275', '1.50', '93.30');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('13', 'DX51D Z100 91x1.5', 'DX51D', 'Z100', '1.50', '91.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('14', 'DX51D Z100 88.8x2', 'DX51D', 'Z100', '2.00', '88.80');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('15', 'DX51D Z275 136x2', 'DX51D', 'Z275', '2.00', '136.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('16', 'DX51D Z275 133x2.5', 'DX51D', 'Z275', '2.50', '133.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('17', 'DX51D Z275 99x1.5', 'DX51D', 'Z275', '1.50', '99.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('18', 'DX51D Z275 96x2', 'DX51D', 'Z275', '2.00', '96.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('19', 'DX51D Z275 79x1.5', 'DX51D', 'Z275', '1.50', '79.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('20', 'DX51D Z275 85.5x2', 'DX51D', 'Z275', '2.00', '85.50');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('21', 'DX51D Z100 124.3x2', 'DX51D', 'Z100', '2.00', '124.30');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('22', 'DX51D Z275 136.5x2', 'DX51D', 'Z275', '2.00', '136.50');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('23', 'DX51D Z275 43.5x1', 'DX51D', 'Z275', '1.00', '43.50');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('24', 'DX51D Z100 130x1', 'DX51D', 'Z100', '1.00', '130.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('25', 'DX51D Z100 94x1', 'DX51D', 'Z100', '1.00', '94.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('26', 'DX51D Z100 92.8x1.2', 'DX51D', 'Z100', '1.20', '92.80');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('27', 'S250GD Z275 90x2', 'S250GD', 'Z275', '2.00', '90.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('28', 'S250GD Z275 70x2', 'S250GD', 'Z275', '2.00', '70.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('29', 'DX51D Z275 93.6x1.5', 'DX51D', 'Z275', '1.50', '93.60');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('30', 'DX51D Z275 65x1.5', 'DX51D', 'Z275', '1.50', '65.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('34', 'DX51D Z275 66.5x2', 'DX51D', 'Z275', '2.00', '66.50');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('35', 'DX51D Z275 56.5x2', 'DX51D', 'Z275', '2.00', '56.50');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('36', 'DX51D Z275 46.5x2', 'DX51D', 'Z275', '2.00', '46.50');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('38', 'S250GD Z275 66x1.2', 'S250GD', 'Z275', '1.20', '66.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('39', 'S250GD Z275 60.5x2', 'S250GD', 'Z275', '2.00', '60.50');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('43', 'DX51D Z100 92x1.2', 'DX51D', 'Z100', '1.20', '92.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('44', 'DX51D Z275 46x1', 'DX51D', 'Z275', '1.00', '46.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('45', 'DX51D Z275 81.4x1.5', 'DX51D', 'Z275', '1.50', '81.40');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('46', 'DX51D Z275 80.2x2', 'DX51D', 'Z275', '2.00', '80.20');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('48', 'DX51D Z100 136.5x1', 'DX51D', 'Z100', '1.00', '136.50');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('49', 'DX51D Z100 116.5x1', 'DX51D', 'Z100', '1.00', '116.50');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('50', 'S235JR CZARNA 92x2', 'S235JR', 'CZARNA', '2.00', '92.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('51', 'DX51D Z275 93x2.5', 'DX51D', 'Z275', '2.50', '93.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('52', 'DX51D Z275 45x0.8', 'DX51D', 'Z275', '0.80', '45.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('53', 'DX51D Z275 36.2x0.8', 'DX51D', 'Z275', '0.80', '36.20');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('54', 'DX51D Z275 29.3x0.8', 'DX51D', 'Z275', '0.80', '29.30');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('55', 'DX51D Z275 57.2x0.8', 'DX51D', 'Z275', '0.80', '57.20');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('56', 'DX51D Z100 73x0.5', 'DX51D', 'Z100', '0.50', '73.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('57', 'DX51D Z100 104.8x0.5', 'DX51D', 'Z100', '0.50', '104.80');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('58', 'DX51D Z100 60x0.5', 'DX51D', 'Z100', '0.50', '60.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('59', 'DX51D Z100 121x0.5', 'DX51D', 'Z100', '0.50', '121.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('60', 'DX51D Z100 51.4x0.5', 'DX51D', 'Z100', '0.50', '51.40');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('61', 'DX51D Z100 88.6x0.5', 'DX51D', 'Z100', '0.50', '88.60');

-- Dane z tabeli `lokalizacja`
INSERT INTO `lokalizacja` (id, nazwa) VALUES ('1', 'Magazyn1');

-- Dane z tabeli `dlugosci`
INSERT INTO `dlugosci` (id, nazwa) VALUES ('3', '1');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('2', '2');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('1', '3');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('4', '4');

-- Dane z tabeli `tasma`
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('51', '2025-04-15', '0.50', '38.60', '1025.00', '0.00', '-', '0085-1', '1', 'WZ16042025', '2025-05-15', '1', '6', '11', '2026-04-22');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('52', '2025-04-15', '0.50', '38.60', '1022.00', '400.00', '-', '0085-2', '1', 'WZ16042025', '2025-05-15', '1', '6', '11', '2026-04-22');

-- Dane z tabeli `profil`
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('59', '51', '2025-04-22', '12:10:31', '12:14:31', '500.00', '3', '461/2025', '3000', '2000', '2', '1', '0', '2026-04-22');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('60', '51', '2025-04-22', '12:31:07', '12:31:31', '0.00', '3', '112', '500', '500', '4', '1', '0', '2026-04-22');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('61', '52', '2025-04-22', '13:00:07', '13:01:34', '500.00', '3', '331', '1000', '1000', '3', '1', '0', '2026-04-22');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('62', '52', '2025-04-22', '13:03:13', '13:03:40', '400.00', '3', '441', '100', '100', '3', '1', 'Jakub K', '2026-04-22');


SET FOREIGN_KEY_CHECKS = 1;
