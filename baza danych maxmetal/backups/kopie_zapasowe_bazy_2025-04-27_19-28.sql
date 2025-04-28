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
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dane z tabeli `uprawnienia`
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES ('1', 'Administrator');
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES ('2', 'Zaopatrzeniowiec ');
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES ('3', 'Pracownik');

-- Dane z tabeli `uzytkownicy`
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES ('1', 'Administrator', 'scrypt:32768:8:1$Hj9SEP8K0oUaPATE$2332f998cad623e8624ec649b50fc69216cad1d0671f4eb9f9a74349e130a156a9db10a084805ef189007bcd31a22c31e072d3ced59e37118e3077bed8d7bcc7', '1');

-- Dane z tabeli `dostawcy`
INSERT INTO `dostawcy` (id, nazwa) VALUES ('1', 'dostawca1');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('2', 'dostawca2');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('5', 'nic');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('3', 'test1');
INSERT INTO `dostawcy` (id, nazwa) VALUES ('4', 'ttttttr');

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
INSERT INTO `dlugosci` (id, nazwa) VALUES ('3', '3');
INSERT INTO `dlugosci` (id, nazwa) VALUES ('4', '4');

-- Dane z tabeli `tasma`
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja_id, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES ('49', '0332-02-23', '1.52', '77.00', '3.00', '0.00', '23', '23', '1', '212', '0002-02-11', '1', '2', '3', '2026-04-21');

-- Dane z tabeli `profil`
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, id_szablon_profile, nazwa_klienta_nr_zlecenia_PRODIO, ilosc, ilosc_na_stanie, id_dlugosci, id_pracownika, Imie_nazwisko_pracownika, Data_do_usuwania) VALUES ('59', '49', '2025-04-27', '19:08:05', '19:08:22', '0.00', '3', '4', '1', '1', '1', '1', '4', '2026-04-27');


SET FOREIGN_KEY_CHECKS = 1;
