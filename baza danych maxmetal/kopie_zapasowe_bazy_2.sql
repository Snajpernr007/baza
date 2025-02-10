CREATE TABLE `uprawnienia` (
  `id_uprawnienia` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id_uprawnienia`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `uzytkownicy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` text DEFAULT NULL,
  `imie` text DEFAULT NULL,
  `nazwisko` text DEFAULT NULL,
  `haslo` text NOT NULL,
  `tel` varchar(9) DEFAULT NULL,
  `id_uprawnienia` int(11) NOT NULL DEFAULT 2,
  PRIMARY KEY (`id`),
  KEY `fk_uzytkownicy_uprawnienia` (`id_uprawnienia`),
  CONSTRAINT `fk_uzytkownicy_uprawnienia` FOREIGN KEY (`id_uprawnienia`) REFERENCES `uprawnienia` (`id_uprawnienia`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dane z tabeli uprawnienia
INSERT INTO uprawnienia (id_uprawnienia, nazwa) VALUES (1, 'admin');
INSERT INTO uprawnienia (id_uprawnienia, nazwa) VALUES (2, 'user');
INSERT INTO uprawnienia (id_uprawnienia, nazwa) VALUES (3, 'pracownik');

-- Dane z tabeli uzytkownicy
INSERT INTO uzytkownicy (id, email, imie, nazwisko, haslo, tel, id_uprawnienia) VALUES (1, 'kuba852@interia.pl', 'Kuba', 'Kaczmarek', 'scrypt:32768:8:1$hFji6Y2E4ieYI6Bp$d019011fb8ea6f21b31c18f54dbbf95f664ed512a7ffc0bb4a2a9b28b709e5fd7b5766675d7a7223aacc24bfdae9b038c22d61f6a1d00a212611c80e068ec153', '123123123', 1);
INSERT INTO uzytkownicy (id, email, imie, nazwisko, haslo, tel, id_uprawnienia) VALUES (2, 'test@test.test', 'test1', 'test', 'scrypt:32768:8:1$J2xa1z92q5qWqVW0$dfb9cfb6e6740e0ae67970017672de7e54c5a304e346fd7446d595887ccf021a2551722d6847c11fd68f65c3db6fad214a24dfcc7bf2862ba08eb1cd3e5f80c7', '111222333', 3);
INSERT INTO uzytkownicy (id, email, imie, nazwisko, haslo, tel, id_uprawnienia) VALUES (3, 'j.kaczmarek@zset.pl', 'jakub', 'kaczmarek', 'scrypt:32768:8:1$TYQvB348f1lan06f$63841d78dabe78e9b9b5853478127a37b0e36ae85373ec0e631bf73151eba467d47ff521b70ebed1e27d4f1056897a636e15b486627d8cdaca205c8d72c82512', '1234', 2);
INSERT INTO uzytkownicy (id, email, imie, nazwisko, haslo, tel, id_uprawnienia) VALUES (4, 'a.grobelny@zset.leszno.pl', 'Aleksander', 'Grobelny', 'scrypt:32768:8:1$wQsdwzTflWGcNBFm$f1389568dd4d676de116c404271613a845b30602adea347e7d4d8daa18cc8b59cc8adaece0fa7b87b46e4309a7a3c863950000246f52ac556c2d7eee8dccd363', '123443111', 1);
INSERT INTO uzytkownicy (id, email, imie, nazwisko, haslo, tel, id_uprawnienia) VALUES (5, 'd.bondar@zset.leszno.pl', NULL, NULL, 'scrypt:32768:8:1$CUMRya11xFSKhDJF$1006474992234514121ed983178d499ce31a620630b522b2c8524a684e5ff0cd622517c79e62523c161907f45d0658121f694de48c7acb650fe7daa170597c5b', '111222333', 1);
INSERT INTO uzytkownicy (id, email, imie, nazwisko, haslo, tel, id_uprawnienia) VALUES (6, 'j.kaczmarek@zset.leszno.pl', 'Kuba', 'Kaczmarek', 'scrypt:32768:8:1$t8b71Ess1UGDFs0g$828d2f38a024cb97a35ab2ccb32bf1406d403d0f514cdbe872a0d409c47bbc26e21885c6c2a520f3a6b0f3ba784049457024444588997908a38c3d470bc3fa96', '609578204', 2);

-- Dane z tabeli tasma
INSERT INTO tasma (id, nazwa_dostawcy, nazwa_materialu, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id) VALUES (1, '1', '2025-02-01', '0000-00-00', 19.00, 0.00, 4.00, '4444', '1', '1', '12', '0000-00-00', NULL);
INSERT INTO tasma (id, nazwa_dostawcy, nazwa_materialu, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id) VALUES (2, '1', '1', '0001-01-01', 1.00, 1.00, 0.00, '1', '1', '1', '1', '0001-01-01', 1);
INSERT INTO tasma (id, nazwa_dostawcy, nazwa_materialu, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id) VALUES (3, '8', '8', '0008-08-08', 8.00, 8.00, 3.00, '4', '8', '8', '8', '0008-08-08', 1);

-- Dane z tabeli profil
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, etykieta_klienta, id_pracownika) VALUES (1, 3, '2025-02-01', 19:17:51, 19:18:08, 0.00, '4', '7', '0.00', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, etykieta_klienta, id_pracownika) VALUES (2, 2, '2025-02-02', 23:20:57, 23:21:14, 0.00, '6', '6', '6', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, etykieta_klienta, id_pracownika) VALUES (3, 1, '2025-02-02', 23:21:26, 23:21:40, 0.00, '333', '8', '8', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, etykieta_klienta, id_pracownika) VALUES (4, 3, '2025-02-02', 23:21:44, 23:21:50, 3.00, '3', '3', '3', 1);

