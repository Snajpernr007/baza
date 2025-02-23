CREATE TABLE `uprawnienia` (
  `id_uprawnienia` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id_uprawnienia`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `uzytkownicy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` text DEFAULT NULL,
  `imie` text DEFAULT NULL,
  `nazwisko` text DEFAULT NULL,
  `haslo` text NOT NULL,
  `id_uprawnienia` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_uzytkownicy_uprawnienia` (`id_uprawnienia`),
  CONSTRAINT `fk_uzytkownicy_uprawnienia` FOREIGN KEY (`id_uprawnienia`) REFERENCES `uprawnienia` (`id_uprawnienia`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `tasma` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa_dostawcy` varchar(255) NOT NULL,
  `nazwa_materialu` varchar(255) NOT NULL,
  `data_z_etykiety_na_kregu` date NOT NULL,
  `grubosc` decimal(10,2) NOT NULL,
  `szerokosc` decimal(10,2) NOT NULL,
  `waga_kregu` decimal(10,2) NOT NULL,
  `nr_etykieta_paletowa` varchar(255) NOT NULL,
  `nr_z_etykiety_na_kregu` varchar(255) NOT NULL,
  `lokalizacja` varchar(255) NOT NULL,
  `nr_faktury_dostawcy` varchar(255) NOT NULL,
  `data_dostawy` date NOT NULL,
  `pracownik_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_tasma_pracownik` (`pracownik_id`),
  CONSTRAINT `fk_tasma_pracownik` FOREIGN KEY (`pracownik_id`) REFERENCES `uzytkownicy` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `profil` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_tasmy` int(11) NOT NULL,
  `data_produkcji` date NOT NULL,
  `godz_min_rozpoczecia` time NOT NULL,
  `godz_min_zakonczenia` time NOT NULL,
  `zwrot_na_magazyn_kg` decimal(10,2) DEFAULT NULL,
  `nr_czesci_klienta` varchar(50) NOT NULL,
  `nazwa_klienta_nr_zlecenia_PRODIO` varchar(100) DEFAULT NULL,
  `etykieta_klienta` varchar(50) NOT NULL,
  `id_pracownika` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_tasmy` (`id_tasmy`),
  KEY `id_pracownika` (`id_pracownika`),
  CONSTRAINT `profil_ibfk_1` FOREIGN KEY (`id_tasmy`) REFERENCES `tasma` (`id`) ON DELETE CASCADE,
  CONSTRAINT `profil_ibfk_2` FOREIGN KEY (`id_pracownika`) REFERENCES `uzytkownicy` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dane z tabeli uprawnienia
INSERT INTO uprawnienia (id_uprawnienia, nazwa) VALUES (1, 'Administrator');
INSERT INTO uprawnienia (id_uprawnienia, nazwa) VALUES (2, 'Zaopatrzeniowiec ');
INSERT INTO uprawnienia (id_uprawnienia, nazwa) VALUES (3, 'Pracownik');

-- Dane z tabeli uzytkownicy
INSERT INTO uzytkownicy (id, login, imie, nazwisko, haslo, id_uprawnienia) VALUES (1, 'Administrator', 'Administrator', 'Administrator', 'scrypt:32768:8:1$hFji6Y2E4ieYI6Bp$d019011fb8ea6f21b31c18f54dbbf95f664ed512a7ffc0bb4a2a9b28b709e5fd7b5766675d7a7223aacc24bfdae9b038c22d61f6a1d00a212611c80e068ec153', 1);
INSERT INTO uzytkownicy (id, login, imie, nazwisko, haslo, id_uprawnienia) VALUES (14, 'test', 'test', 'test', 'scrypt:32768:8:1$Uct0oowQ3WNJzvdN$35be1bbcc5187ab6df61fb6f539c7fd4ef4e412e890b607c7b9b33345edd4311b276d58b56c3229ab36788f0b8da4a56f4705a4b2fb4108b247bc0dead1b729b', 3);

-- Dane z tabeli tasma
INSERT INTO tasma (id, nazwa_dostawcy, nazwa_materialu, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id) VALUES (1, '1', '2025-02-01', '1111-01-12', 19.00, 0.00, 0.00, '4444', '1', '1', '12', '0000-00-00', 1);
INSERT INTO tasma (id, nazwa_dostawcy, nazwa_materialu, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id) VALUES (2, '1', '1', '0001-01-01', 1.00, 1.00, 0.00, '1', '1', '1', '1', '0001-01-01', 1);
INSERT INTO tasma (id, nazwa_dostawcy, nazwa_materialu, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id) VALUES (3, '8', '8', '0008-08-08', 8.00, 8.00, 2.00, '4', '8', '8', '8', '0008-08-08', 1);
INSERT INTO tasma (id, nazwa_dostawcy, nazwa_materialu, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id) VALUES (4, '2342', '3424', '0034-04-04', 423.00, 234.00, 234.00, '234', '243', '243', '243', '0423-04-23', 1);
INSERT INTO tasma (id, nazwa_dostawcy, nazwa_materialu, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id) VALUES (5, '2', '2', '0022-02-22', 22.00, 2.00, 2.00, '2', '2', '22', '2', '0002-02-22', 1);
INSERT INTO tasma (id, nazwa_dostawcy, nazwa_materialu, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id) VALUES (6, '5', '5', '0005-05-05', 55.00, 55.00, 55.00, '55', '55', '55', '55', '0005-05-05', 1);

-- Dane z tabeli profil
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, etykieta_klienta, id_pracownika) VALUES (1, 3, '2025-02-01', 19:17:51, 19:18:08, 0.00, '4', '7', '0.00', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, etykieta_klienta, id_pracownika) VALUES (2, 2, '2025-02-02', 23:20:57, 23:21:14, 0.00, '6', '6', '6', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, etykieta_klienta, id_pracownika) VALUES (3, 1, '2025-02-02', 23:21:26, 23:21:40, 0.00, '333', '8', '8', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, etykieta_klienta, id_pracownika) VALUES (4, 3, '2025-02-02', 23:21:44, 23:21:50, 3.00, '3', '3', '3', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, etykieta_klienta, id_pracownika) VALUES (5, 1, '2025-02-10', 14:24:21, 14:24:27, 11.00, '11', '11', '11', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, etykieta_klienta, id_pracownika) VALUES (6, 1, '2025-02-10', 14:42:49, 14:42:59, 11.00, '1', '1', '1', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, etykieta_klienta, id_pracownika) VALUES (7, 1, '2025-02-16', 19:20:41, 19:20:46, 0.00, '0', '0', '0', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, etykieta_klienta, id_pracownika) VALUES (8, 3, '2025-02-16', 19:33:25, 19:33:33, 2.00, '4', '4', '4', 1);

