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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `dostawcy`
CREATE TABLE `dostawcy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nazwa` (`nazwa`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `rozmiary_obejm`
CREATE TABLE `rozmiary_obejm` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  `ile_pianka` int(11) NOT NULL,
  `ile_tasma` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `material_obejma`
CREATE TABLE `material_obejma` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `certyfikat` varchar(255) DEFAULT NULL,
  `data_dostawy` date DEFAULT NULL,
  `nr_wytopu` varchar(100) DEFAULT NULL,
  `nr_prodio` varchar(100) DEFAULT NULL,
  `ilosc_sztuk` int(11) DEFAULT NULL,
  `ilosc_sztuk_na_stanie` int(11) DEFAULT NULL,
  `id_rozmiaru` int(11) DEFAULT NULL,
  `id_pracownik` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_rozmiaru` (`id_rozmiaru`),
  KEY `id_pracownik` (`id_pracownik`),
  CONSTRAINT `material_obejma_ibfk_1` FOREIGN KEY (`id_rozmiaru`) REFERENCES `rozmiary_obejm` (`id`),
  CONSTRAINT `material_obejma_ibfk_2` FOREIGN KEY (`id_pracownik`) REFERENCES `uzytkownicy` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `ksztaltowanie_1`
CREATE TABLE `ksztaltowanie_1` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` date DEFAULT NULL,
  `godzina_rozpoczecia` time DEFAULT NULL,
  `godzina_zakonczenia` time DEFAULT NULL,
  `ilosc` int(11) DEFAULT NULL,
  `ilosc_na_stanie` int(11) DEFAULT NULL,
  `nr_prodio` varchar(100) DEFAULT NULL,
  `id_materialu` int(11) DEFAULT NULL,
  `id_pracownik` int(11) DEFAULT NULL,
  `imie_nazwisko` varchar(255) DEFAULT NULL,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_materialu` (`id_materialu`),
  KEY `id_pracownik` (`id_pracownik`),
  CONSTRAINT `ksztaltowanie_1_ibfk_1` FOREIGN KEY (`id_materialu`) REFERENCES `material_obejma` (`id`),
  CONSTRAINT `ksztaltowanie_1_ibfk_2` FOREIGN KEY (`id_pracownik`) REFERENCES `uzytkownicy` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `ksztaltowanie_2`
CREATE TABLE `ksztaltowanie_2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_ksztaltowanie_1` int(11) DEFAULT NULL,
  `data` date DEFAULT NULL,
  `godzina_rozpoczecia` time DEFAULT NULL,
  `godzina_zakonczenia` time DEFAULT NULL,
  `ilosc` int(11) DEFAULT NULL,
  `ilosc_na_stanie` int(11) DEFAULT NULL,
  `nr_prodio` varchar(100) DEFAULT NULL,
  `id_pracownik` int(11) DEFAULT NULL,
  `imie_nazwisko` varchar(255) DEFAULT NULL,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_ksztaltowanie_1` (`id_ksztaltowanie_1`),
  KEY `id_pracownik` (`id_pracownik`),
  CONSTRAINT `ksztaltowanie_2_ibfk_1` FOREIGN KEY (`id_ksztaltowanie_1`) REFERENCES `ksztaltowanie_1` (`id`),
  CONSTRAINT `ksztaltowanie_2_ibfk_2` FOREIGN KEY (`id_pracownik`) REFERENCES `uzytkownicy` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `ksztaltowanie_3`
CREATE TABLE `ksztaltowanie_3` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_ksztaltowanie_2` int(11) DEFAULT NULL,
  `data` date DEFAULT NULL,
  `godzina_rozpoczecia` time DEFAULT NULL,
  `godzina_zakonczenia` time DEFAULT NULL,
  `ilosc` int(11) DEFAULT NULL,
  `ilosc_na_stanie` int(11) DEFAULT NULL,
  `nr_prodio` varchar(100) DEFAULT NULL,
  `id_pracownik` int(11) DEFAULT NULL,
  `imie_nazwisko` varchar(255) DEFAULT NULL,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_ksztaltowanie_2` (`id_ksztaltowanie_2`),
  KEY `id_pracownik` (`id_pracownik`),
  CONSTRAINT `ksztaltowanie_3_ibfk_1` FOREIGN KEY (`id_ksztaltowanie_2`) REFERENCES `ksztaltowanie_2` (`id`),
  CONSTRAINT `ksztaltowanie_3_ibfk_2` FOREIGN KEY (`id_pracownik`) REFERENCES `uzytkownicy` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `malarnia`
CREATE TABLE `malarnia` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_ksztaltowanie_3` int(11) DEFAULT NULL,
  `ilosc` int(11) DEFAULT NULL,
  `ilosc_na_stanie` int(11) DEFAULT NULL,
  `nr_prodio` varchar(100) DEFAULT NULL,
  `data` date DEFAULT NULL,
  `id_pracownik` int(11) DEFAULT NULL,
  `imie_nazwisko` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_pracownik` (`id_pracownik`),
  KEY `malarnia_ibfk_1` (`id_ksztaltowanie_3`),
  CONSTRAINT `malarnia_ibfk_1` FOREIGN KEY (`id_ksztaltowanie_3`) REFERENCES `ksztaltowanie_3` (`id`),
  CONSTRAINT `malarnia_ibfk_2` FOREIGN KEY (`id_pracownik`) REFERENCES `uzytkownicy` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `powrot`
CREATE TABLE `powrot` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` date DEFAULT NULL,
  `ilosc` int(11) DEFAULT NULL,
  `ilosc_na_stanie` int(11) DEFAULT NULL,
  `nr_prodio` varchar(100) DEFAULT NULL,
  `id_malowania` int(11) DEFAULT NULL,
  `id_pracownik` int(11) DEFAULT NULL,
  `imie_nazwisko` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_malowania` (`id_malowania`),
  KEY `id_pracownik` (`id_pracownik`),
  CONSTRAINT `powrot_ibfk_1` FOREIGN KEY (`id_malowania`) REFERENCES `malarnia` (`id`),
  CONSTRAINT `powrot_ibfk_2` FOREIGN KEY (`id_pracownik`) REFERENCES `uzytkownicy` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `pianka`
CREATE TABLE `pianka` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(100) NOT NULL,
  `ilosc` int(11) DEFAULT 0,
  `ilosc_na_stanie` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `tasma_obejmy`
CREATE TABLE `tasma_obejmy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(100) NOT NULL,
  `ilosc` int(11) DEFAULT 0,
  `ilosc_na_stanie` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `zlecenie`
CREATE TABLE `zlecenie` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nr_zamowienia_zew` varchar(100) DEFAULT NULL,
  `nr_prodio` varchar(100) DEFAULT NULL,
  `id_pianka` int(11) DEFAULT NULL,
  `ile_pianka` int(11) NOT NULL,
  `id_tasma` int(11) DEFAULT NULL,
  `ile_tasmy` int(11) DEFAULT NULL,
  `nr_kartonu` varchar(100) DEFAULT NULL,
  `id_pracownik` int(11) DEFAULT NULL,
  `imie_nazwisko` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_pracownik` (`id_pracownik`),
  KEY `zlecenie_ibfk_2` (`id_pianka`),
  KEY `zlecenie_ibfk_3` (`id_tasma`),
  CONSTRAINT `zlecenie_ibfk_1` FOREIGN KEY (`id_pracownik`) REFERENCES `uzytkownicy` (`id`),
  CONSTRAINT `zlecenie_ibfk_2` FOREIGN KEY (`id_pianka`) REFERENCES `pianka` (`id`) ON DELETE SET NULL,
  CONSTRAINT `zlecenie_ibfk_3` FOREIGN KEY (`id_tasma`) REFERENCES `tasma_obejmy` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `laczenie`
CREATE TABLE `laczenie` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_zlecenie` int(11) DEFAULT NULL,
  `id_powrot` int(11) DEFAULT NULL,
  `ile_sztuk` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_zlecenie` (`id_zlecenie`),
  KEY `id_powrot` (`id_powrot`),
  CONSTRAINT `laczenie_ibfk_1` FOREIGN KEY (`id_zlecenie`) REFERENCES `zlecenie` (`id`),
  CONSTRAINT `laczenie_ibfk_2` FOREIGN KEY (`id_powrot`) REFERENCES `powrot` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dane z tabeli `uprawnienia`
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES ('1', 'Administrator');
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES ('2', 'Zaopatrzeniowiec ');
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES ('3', 'Pracownik');

-- Dane z tabeli `uzytkownicy`
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES ('1', 'Administrator', 'scrypt:32768:8:1$UCBwCJVWPxR43fNh$e822900a3b12c3c4ac274af1701eedd757ba770bba15d8994d2814684fceaed06db771d8ed214e75ec9cb2d9a95ccf7e01b3c4f49bc407c52fe141547a91077b', '1');
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES ('19', 'test4', 'scrypt:32768:8:1$GsL9GxyDMPYKUS5M$5bf70ac57ecb3a3bdf1e83b676de9f1534be0c8d1d30c02cb65bb26dd9441c8a4fc4057237df9ce59f91deff5989b5c941eefaca267ee8dfb4298161abadb65e', '3');
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES ('20', 'test5', 'scrypt:32768:8:1$dNUmTnd7ZwVAjUJx$4e6e57c0802dc3bb5b6d73f051003d51aeb022f920954ceabd89cfd982bc795d86a1549a49ffc6bfdea1eedd444884d45467a94d46e118dd7bc162d9ab90ea41', '1');

-- Dane z tabeli `dostawcy`
INSERT INTO `dostawcy` (id, nazwa) VALUES ('1', 'dostawca1');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('2', 'dostawca2');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('5', 'nic');
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

-- Dane z tabeli `lokalizacja`
INSERT INTO `lokalizacja` (id, nazwa) VALUES ('1', 'Magazyn11');

-- Dane z tabeli `dlugosci`
INSERT INTO `dlugosci` (id, nazwa) VALUES ('1', '1');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('2', '2');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('5', '2.5');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('3', '3');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('4', '4');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('6', '5');

-- Dane z tabeli `tasma`
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('51', '0023-03-31', '1.52', '77.00', '23.00', '0.00', '23', '23', '1', '32', '0002-03-22', '1', '1', '3', '2026-04-27');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('53', '2025-06-25', '0.00', '0.00', '5.00', '0.00', '5', '4', '1', '15472', '2025-04-25', '1', '1', '4', '2026-04-28');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('54', '0576-06-07', '0.00', '0.00', '765.00', '0.00', '756', '756', '1', '576', '0006-05-07', '1', '5', '4', '2026-04-28');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('55', '2025-08-08', '1.52', '77.00', '324.00', '10.00', '342', '234', '1', '234', '0434-04-04', '20', '1', '3', '2026-05-06');

-- Dane z tabeli `szablon_profile`
INSERT INTO `szablon_profile` (id, nazwa, waga_w_kg_na_1_metr) VALUES ('3', '1235', '7.00');
INSERT INTO `szablon_profile` (id, nazwa, waga_w_kg_na_1_metr) VALUES ('4', 'fdgdfhdfgs', '6.98');

-- Dane z tabeli `profil`
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('69', '53', '2025-04-28', '20:43:31', '20:44:07', '0.00', '3', '64', '342', '342', '6', '1', '6', '2026-04-28');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('70', '54', '2025-05-06', '12:28:55', '12:29:15', '111.00', '3', '213', '11', '11', '1', '1', '213', '2026-05-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('71', '54', '2025-05-06', '12:48:34', '12:48:45', '1.00', '4', '213', '123', '123', '3', '19', '123', '2026-05-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('72', '55', '2025-05-06', '14:45:40', '14:48:29', '0.00', '3', '7', '1', '1', '1', '1', '7', '2026-05-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('73', '55', '2025-05-06', '14:51:25', '14:51:50', '0.00', '3', '76', '1', '1', '1', '1', '567', '2026-05-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('74', '55', '2025-05-06', '15:34:12', '15:35:22', '59.02', '4', '6', '1', '1', '3', '1', '6', '2026-05-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('75', '54', '2025-05-07', '12:06:21', NULL, NULL, '3', '45334', NULL, NULL, NULL, '1', '534543', '2026-05-07');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('76', '55', '2025-05-25', '19:08:53', '19:10:26', '30.00', '3', 'warlawen', '60', '60', '6', '1', 'Kuba Kaczmarek', '2026-05-25');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('77', '55', '2025-05-27', '12:44:30', '12:46:19', '10.00', '3', 'WZ123', '1000', '1000', '6', '19', 'Jakub Kaczmarek', '2026-05-27');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('78', '54', '2025-07-17', '14:26:52', '14:27:40', '0.00', '3', '12', '2', '2', '2', '1', '12', '2026-07-17');

-- Dane z tabeli `rozmiary_obejm`
INSERT INTO `rozmiary_obejm` (id, nazwa, ile_pianka, ile_tasma) VALUES ('1', '231', '2', '2');
INSERT INTO `rozmiary_obejm` (id, nazwa, ile_pianka, ile_tasma) VALUES ('2', 'sda2', '0', '0');
INSERT INTO `rozmiary_obejm` (id, nazwa, ile_pianka, ile_tasma) VALUES ('3', '55', '132', '21');

-- Dane z tabeli `material_obejma`
INSERT INTO `material_obejma` (id, certyfikat, data_dostawy, nr_wytopu, nr_prodio, ilosc_sztuk, ilosc_sztuk_na_stanie, id_rozmiaru, id_pracownik) VALUES ('2', NULL, '6765-05-07', '765', '756', '756', '0', '1', '1');
INSERT INTO `material_obejma` (id, certyfikat, data_dostawy, nr_wytopu, nr_prodio, ilosc_sztuk, ilosc_sztuk_na_stanie, id_rozmiaru, id_pracownik) VALUES ('8', '435', '0345-05-31', '435', '345', '345', '0', '2', '1');
INSERT INTO `material_obejma` (id, certyfikat, data_dostawy, nr_wytopu, nr_prodio, ilosc_sztuk, ilosc_sztuk_na_stanie, id_rozmiaru, id_pracownik) VALUES ('9', 'tew', '0013-12-31', '123', '123', '123', '0', '1', '1');

-- Dane z tabeli `ksztaltowanie_1`
INSERT INTO `ksztaltowanie_1` (id, data, godzina_rozpoczecia, godzina_zakonczenia, ilosc, ilosc_na_stanie, nr_prodio, id_materialu, id_pracownik, imie_nazwisko, nazwa) VALUES ('4', '2025-07-17', '14:14:36', '14:14:41', '23', '0', '23', '2', '1', '23', '1/23/66/765/2025-07-17');
INSERT INTO `ksztaltowanie_1` (id, data, godzina_rozpoczecia, godzina_zakonczenia, ilosc, ilosc_na_stanie, nr_prodio, id_materialu, id_pracownik, imie_nazwisko, nazwa) VALUES ('5', '2025-07-17', '20:49:00', '20:49:34', '23', '23', '23', '2', NULL, '232', 'Nazwa z innej tabeli lub logiki');
INSERT INTO `ksztaltowanie_1` (id, data, godzina_rozpoczecia, godzina_zakonczenia, ilosc, ilosc_na_stanie, nr_prodio, id_materialu, id_pracownik, imie_nazwisko, nazwa) VALUES ('6', '2025-07-17', '20:58:53', '20:59:14', '34', NULL, '34', '2', '1', '3', '4/34/231/765/2025-07-17');
INSERT INTO `ksztaltowanie_1` (id, data, godzina_rozpoczecia, godzina_zakonczenia, ilosc, ilosc_na_stanie, nr_prodio, id_materialu, id_pracownik, imie_nazwisko, nazwa) VALUES ('7', '2025-07-17', '21:53:26', '21:57:20', '246', NULL, '21', '2', '1', '1', '4/21/231/765/2025-07-17');
INSERT INTO `ksztaltowanie_1` (id, data, godzina_rozpoczecia, godzina_zakonczenia, ilosc, ilosc_na_stanie, nr_prodio, id_materialu, id_pracownik, imie_nazwisko, nazwa) VALUES ('8', '2025-07-17', '21:58:24', '21:58:36', '-123213123', '123', '123', '9', '1', '123', '4/123/231/123/2025-07-17');
INSERT INTO `ksztaltowanie_1` (id, data, godzina_rozpoczecia, godzina_zakonczenia, ilosc, ilosc_na_stanie, nr_prodio, id_materialu, id_pracownik, imie_nazwisko, nazwa) VALUES ('9', '2025-07-18', '9:37:03', '9:37:15', '345', '345', '123', '8', '1', '123', '9/123/sda2/435/2025-07-18');

-- Dane z tabeli `ksztaltowanie_2`
INSERT INTO `ksztaltowanie_2` (id, id_ksztaltowanie_1, data, godzina_rozpoczecia, godzina_zakonczenia, ilosc, ilosc_na_stanie, nr_prodio, id_pracownik, imie_nazwisko, nazwa) VALUES ('3', '4', '2025-07-17', '14:15:12', '14:15:17', '23', '0', '23', '1', '23', '1/23/66/765/2025-07-17');
INSERT INTO `ksztaltowanie_2` (id, id_ksztaltowanie_1, data, godzina_rozpoczecia, godzina_zakonczenia, ilosc, ilosc_na_stanie, nr_prodio, id_pracownik, imie_nazwisko, nazwa) VALUES ('4', '8', '2025-07-18', '9:34:25', '9:36:43', '123213123', '123213123', '213', '1', '123', '4/213/231/123/2025-07-18');
INSERT INTO `ksztaltowanie_2` (id, id_ksztaltowanie_1, data, godzina_rozpoczecia, godzina_zakonczenia, ilosc, ilosc_na_stanie, nr_prodio, id_pracownik, imie_nazwisko, nazwa) VALUES ('5', '8', '2025-07-18', '9:35:59', '9:36:19', '123', '123', '123', '1', '123', '5/123/231/123/2025-07-18');

-- Dane z tabeli `ksztaltowanie_3`
INSERT INTO `ksztaltowanie_3` (id, id_ksztaltowanie_2, data, godzina_rozpoczecia, godzina_zakonczenia, ilosc, ilosc_na_stanie, nr_prodio, id_pracownik, imie_nazwisko, nazwa) VALUES ('3', '3', '2025-07-17', '14:15:21', '14:15:25', '23', '0', '23', '1', '23', '1/23/66/765/2025-07-17');

-- Dane z tabeli `malarnia`
INSERT INTO `malarnia` (id, id_ksztaltowanie_3, ilosc, ilosc_na_stanie, nr_prodio, data, id_pracownik, imie_nazwisko) VALUES ('9', '3', '23', '22', '23', '0323-02-23', '1', '2332');

-- Dane z tabeli `powrot`
INSERT INTO `powrot` (id, data, ilosc, ilosc_na_stanie, nr_prodio, id_malowania, id_pracownik, imie_nazwisko) VALUES ('5', '0332-02-23', '23', '230539', '23', '9', '1', '2323');
INSERT INTO `powrot` (id, data, ilosc, ilosc_na_stanie, nr_prodio, id_malowania, id_pracownik, imie_nazwisko) VALUES ('6', '0123-03-12', '23', '0', '132', '9', '1', '123');

-- Dane z tabeli `pianka`
INSERT INTO `pianka` (id, nazwa, ilosc, ilosc_na_stanie) VALUES ('1', '231', '1236', '117');
INSERT INTO `pianka` (id, nazwa, ilosc, ilosc_na_stanie) VALUES ('2', '6', '6', '0');

-- Dane z tabeli `tasma_obejmy`
INSERT INTO `tasma_obejmy` (id, nazwa, ilosc, ilosc_na_stanie) VALUES ('1', '6', '6', '0');
INSERT INTO `tasma_obejmy` (id, nazwa, ilosc, ilosc_na_stanie) VALUES ('2', '3', '6', '0');

-- Dane z tabeli `zlecenie`
INSERT INTO `zlecenie` (id, nr_zamowienia_zew, nr_prodio, id_pianka, ile_pianka, id_tasma, ile_tasmy, nr_kartonu, id_pracownik, imie_nazwisko) VALUES ('6', '321', '123', '1', '2', '2', '2', '2', '1', '123');
INSERT INTO `zlecenie` (id, nr_zamowienia_zew, nr_prodio, id_pianka, ile_pianka, id_tasma, ile_tasmy, nr_kartonu, id_pracownik, imie_nazwisko) VALUES ('7', 'wq', 'wqe', '1', '32', '1', '123', 'weq', '1', 'qwe');
INSERT INTO `zlecenie` (id, nr_zamowienia_zew, nr_prodio, id_pianka, ile_pianka, id_tasma, ile_tasmy, nr_kartonu, id_pracownik, imie_nazwisko) VALUES ('8', '123', '213', '1', '123', '1', '312', '213', '1', '321');
INSERT INTO `zlecenie` (id, nr_zamowienia_zew, nr_prodio, id_pianka, ile_pianka, id_tasma, ile_tasmy, nr_kartonu, id_pracownik, imie_nazwisko) VALUES ('9', '6', '6', '2', '6', '1', '6', '6', '1', '6');
INSERT INTO `zlecenie` (id, nr_zamowienia_zew, nr_prodio, id_pianka, ile_pianka, id_tasma, ile_tasmy, nr_kartonu, id_pracownik, imie_nazwisko) VALUES ('10', '34', '234', '1', '231', '2', '2', '3', '1', 'Administrator');
INSERT INTO `zlecenie` (id, nr_zamowienia_zew, nr_prodio, id_pianka, ile_pianka, id_tasma, ile_tasmy, nr_kartonu, id_pracownik, imie_nazwisko) VALUES ('11', '123', '123', '1', '2312', '2', '22', '2', '1', '132');

-- Dane z tabeli `laczenie`
INSERT INTO `laczenie` (id, id_zlecenie, id_powrot, ile_sztuk) VALUES ('16', '6', '5', '0');
INSERT INTO `laczenie` (id, id_zlecenie, id_powrot, ile_sztuk) VALUES ('17', '8', '5', '321');
INSERT INTO `laczenie` (id, id_zlecenie, id_powrot, ile_sztuk) VALUES ('18', '9', '5', '6');
INSERT INTO `laczenie` (id, id_zlecenie, id_powrot, ile_sztuk) VALUES ('21', '10', '5', '0');
INSERT INTO `laczenie` (id, id_zlecenie, id_powrot, ile_sztuk) VALUES ('26', '11', '5', '66');
INSERT INTO `laczenie` (id, id_zlecenie, id_powrot, ile_sztuk) VALUES ('27', '11', '5', '243');
INSERT INTO `laczenie` (id, id_zlecenie, id_powrot, ile_sztuk) VALUES ('28', '11', '5', '65');


SET FOREIGN_KEY_CHECKS = 1;
