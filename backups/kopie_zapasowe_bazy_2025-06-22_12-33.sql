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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `lokalizacja`
CREATE TABLE `lokalizacja` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `dlugosci`
CREATE TABLE `dlugosci` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nazwa` (`nazwa`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `szablon_profile`
CREATE TABLE `szablon_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  `waga_w_kg_na_1_metr` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `Imie_nazwisko_pracownika` varchar(50) NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dane z tabeli `uprawnienia`
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES ('1', 'Administrator');
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES ('2', 'Zaopatrzeniowiec ');
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES ('3', 'Pracownik');

-- Dane z tabeli `uzytkownicy`
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES ('1', 'Administrator', 'scrypt:32768:8:1$UCBwCJVWPxR43fNh$e822900a3b12c3c4ac274af1701eedd757ba770bba15d8994d2814684fceaed06db771d8ed214e75ec9cb2d9a95ccf7e01b3c4f49bc407c52fe141547a91077b', '1');
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES ('19', 'test4', 'scrypt:32768:8:1$ru0bUjJ8KMhoBWiB$49d1f7d3fd182298e9f5b4ac825740cb790a60287ffa17541291c4338c421f1c7e352a348e196d4c3af39a21506348c7cb6817ddf495bfaa4b7a59d6a5d7de59', '3');
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES ('20', 'Aleks', 'scrypt:32768:8:1$LViPGZQvkqWPGQUz$be90658041523554eb467ddf37855b84a50825b1439c5fb9eba198a49a47a5441da7d35455978767128e4dd3560c535b3818b9f978c04c7b8e68ee35012092cb', '2');
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES ('21', 'Artur', 'scrypt:32768:8:1$VZLQlBHsRqQUUoS5$b923bc20a380aeddbe2ebf91b825400743373381bceba622632738769715b7c807274e44eed955b2e6df1f473cb519815b37f94800faed794b930aaeef911cf0', '3');

-- Dane z tabeli `dostawcy`
INSERT INTO `dostawcy` (id, nazwa) VALUES ('10', '54564');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('6', 'Agromix');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('8', 'Biedronka');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('1', 'dostawca1');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('2', 'dostawca2');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('11', 'fhrg');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('12', 'hytj');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('7', 'Lidl');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('5', 'nic');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('9', 'Szapka');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('3', 'test1');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('4', 'ttttttr6');

-- Dane z tabeli `szablon`
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('1', 'Dx2', 'D', 'x', '77.00', '3.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('2', 'TT', 't', 'r', '1.00', '1.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('3', 'DX510 2275 1,2x66', 'DX510', '2275', '1.52', '77.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('4', 'ww ww wwxww', 'ww', 'ww', '0.00', '0.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('5', '22 22 TruexTrue', '22', '22', '1.00', '1.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('6', 't t TruexTrue', 't', 't', '1.00', '1.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('7', '11 11 11x11', '11', '11', '11.00', '11.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('8', '121 122 8.1x8.2', '121', '122', '8.20', '8.10');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('9', 'ttr 4ewr 4,2x4', 'ttr', '4ewr', '4.20', '4.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('10', 'ttr20 mc4 4x5', 'ttr20', 'mc4', '5.00', '4.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('11', '675 567 687x867', '675', '567', '867.00', '687.00');
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES ('12', '68 687 86x86', '68', '687', '86.00', '86.00');

-- Dane z tabeli `lokalizacja`
INSERT INTO `lokalizacja` (id, nazwa) VALUES ('1', 'Magazyn11');
INSERT INTO `lokalizacja` (id, nazwa) VALUES ('4', 'Dupa');

-- Dane z tabeli `dlugosci`
INSERT INTO `dlugosci` (id, nazwa) VALUES ('14', '-3');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('13', '0');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('1', '1');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('2', '2');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('5', '2.5');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('11', '2354');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('3', '3');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('4', '4');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('6', '5');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('8', '546');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('7', '567');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('10', '56789');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('9', '658749');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('12', '98065');

-- Dane z tabeli `tasma`
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('51', '0023-03-31', '1.52', '77.00', '23.00', '0.00', '23', '23', '1', '32', '0002-03-23', '1', '1', '3', '2026-04-27');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('52', '0033-03-21', '0.00', '0.00', '132.00', '0.00', '321', '321', '1', '213', '0123-03-21', '1', '2', '4', '2026-04-27');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('53', '2025-06-25', '0.00', '0.00', '5.00', '0.00', '5', '4', '1', '15472', '2025-04-25', '1', '1', '4', '2026-04-28');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('54', '0576-06-07', '0.00', '0.00', '765.00', '765.00', '756', '756', '1', '576', '0006-05-07', '1', '5', '4', '2026-04-28');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('55', '2025-06-28', '1.00', '1.00', '645.00', '645.00', '554', '23', '4', '456', '2025-07-09', '1', '1', '2', '2026-06-12');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('56', '2025-06-28', '1.00', '1.00', '645.00', '645.00', '554', '23', '4', '456', '2025-07-09', '1', '1', '2', '2026-06-12');

-- Dane z tabeli `szablon_profile`
INSERT INTO `szablon_profile` (id, nazwa, waga_w_kg_na_1_metr) VALUES ('3', '1235', '0.00');
INSERT INTO `szablon_profile` (id, nazwa, waga_w_kg_na_1_metr) VALUES ('4', '534t2', '234.00');

-- Dane z tabeli `profil`
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('65', '52', '2025-04-28', '19:16:29', '19:16:44', '3.00', '3', '3422', '243', '243', '1', '1', '432', '2026-04-28');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('66', '52', '2025-04-28', '19:16:33', '19:16:50', '2.00', '3', '432', '34', '24', '1', '1', '234', '2026-04-28');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('67', '52', '2025-04-28', '19:17:32', '20:42:55', '0.00', '3', '1', '567', '562', '5', '19', '1', '2026-04-28');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('68', '52', '2025-04-28', '20:42:33', '20:42:47', '1.00', '3', '453', '534', '533', '5', '1', '543', '2026-04-28');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('69', '53', '2025-04-28', '20:43:31', '20:44:07', '0.00', '3', '64', '342', '342', '6', '1', '6', '2026-04-28');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('70', '54', '2025-05-27', '17:31:05', NULL, NULL, '3', '1213', NULL, NULL, NULL, '1', '11213', '2026-05-27');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('71', '54', '2025-06-11', '21:54:20', NULL, NULL, '3', '1213', NULL, NULL, NULL, '1', 'adam', '2026-06-11');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('72', '54', '2025-06-11', '21:54:56', NULL, NULL, '3', '58', NULL, NULL, NULL, '1', 'adam', '2026-06-11');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('73', '54', '2025-06-11', '22:59:25', NULL, NULL, '3', '876', NULL, NULL, NULL, '1', 'adam', '2026-06-11');


SET FOREIGN_KEY_CHECKS = 1;
