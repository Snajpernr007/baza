CREATE TABLE `uprawnienia` (
  `id_uprawnienia` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  PRIMARY KEY (`id_uprawnienia`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `uzytkownicy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` text DEFAULT NULL,
  `haslo` text NOT NULL,
  `id_uprawnienia` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_uzytkownicy_uprawnienia` (`id_uprawnienia`),
  CONSTRAINT `fk_uzytkownicy_uprawnienia` FOREIGN KEY (`id_uprawnienia`) REFERENCES `uprawnienia` (`id_uprawnienia`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `tasma` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_z_etykiety_na_kregu` date NOT NULL,
  `grubosc` decimal(10,2) NOT NULL,
  `szerokosc` decimal(10,2) NOT NULL,
  `waga_kregu` decimal(10,2) NOT NULL,
  `waga_kregu_na_stanie` decimal(10,2) NOT NULL,
  `nr_etykieta_paletowa` varchar(255) NOT NULL,
  `nr_z_etykiety_na_kregu` varchar(255) NOT NULL,
  `lokalizacja` varchar(255) NOT NULL,
  `nr_faktury_dostawcy` varchar(255) NOT NULL,
  `data_dostawy` date NOT NULL,
  `pracownik_id` int(11) DEFAULT NULL,
  `dostawca_id` int(11) NOT NULL,
  `szablon_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_tasma_pracownik` (`pracownik_id`),
  KEY `fk_tasma_dostawca` (`dostawca_id`),
  KEY `fk_tasma_szablon` (`szablon_id`),
  CONSTRAINT `fk_tasma_dostawca` FOREIGN KEY (`dostawca_id`) REFERENCES `dostawcy` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tasma_pracownik` FOREIGN KEY (`pracownik_id`) REFERENCES `uzytkownicy` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_tasma_szablon` FOREIGN KEY (`szablon_id`) REFERENCES `szablon` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `profil` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_tasmy` int(11) NOT NULL,
  `data_produkcji` date NOT NULL,
  `godz_min_rozpoczecia` time NOT NULL,
  `godz_min_zakonczenia` time NOT NULL,
  `zwrot_na_magazyn_kg` decimal(10,2) DEFAULT NULL,
  `nr_czesci_klienta` varchar(50) NOT NULL,
  `nazwa_klienta_nr_zlecenia_PRODIO` varchar(100) DEFAULT NULL,
  `id_pracownika` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_tasmy` (`id_tasmy`),
  KEY `id_pracownika` (`id_pracownika`),
  CONSTRAINT `profil_ibfk_1` FOREIGN KEY (`id_tasmy`) REFERENCES `tasma` (`id`) ON DELETE CASCADE,
  CONSTRAINT `profil_ibfk_2` FOREIGN KEY (`id_pracownika`) REFERENCES `uzytkownicy` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dane z tabeli uprawnienia
INSERT INTO uprawnienia (id_uprawnienia, nazwa) VALUES (1, 'Administrator');
INSERT INTO uprawnienia (id_uprawnienia, nazwa) VALUES (2, 'Zaopatrzeniowiec ');
INSERT INTO uprawnienia (id_uprawnienia, nazwa) VALUES (3, 'Pracownik');

-- Dane z tabeli uzytkownicy
INSERT INTO uzytkownicy (id, login, haslo, id_uprawnienia) VALUES (1, 'Administrator', 'scrypt:32768:8:1$hFji6Y2E4ieYI6Bp$d019011fb8ea6f21b31c18f54dbbf95f664ed512a7ffc0bb4a2a9b28b709e5fd7b5766675d7a7223aacc24bfdae9b038c22d61f6a1d00a212611c80e068ec153', 1);
INSERT INTO uzytkownicy (id, login, haslo, id_uprawnienia) VALUES (14, 'test1', 'scrypt:32768:8:1$g85jfiQGw8D1zVS1$61a4ed4d2ef9a2530b54939d1d472b43b61348c7c11ce5861e434799ec28999ac8e0373060f41d3b0e32e867794e839fa270277770a5f81e451aaf500c15109b', 1);
INSERT INTO uzytkownicy (id, login, haslo, id_uprawnienia) VALUES (15, 'test2t', 'scrypt:32768:8:1$3n3YVd6vI379yWRD$e9fe4bc0dfb88f6345505ba46527cb3e6c21234c09f5329791da5c814e4b5196219f61bfeec6f47b419f01bd9d4538c6f6ca2bd51cf1845e66e225bc34aa851c', 2);
INSERT INTO uzytkownicy (id, login, haslo, id_uprawnienia) VALUES (16, 'test3', 'scrypt:32768:8:1$3zFtfjuCE2ekzMrt$9b1fa256e8c9b2e762949d17a45b6cfe2d544ea726da11fc7688676321ca63c029939ff18cba7b299e6d49f7029875c427282243b6078fbdb29e3de9dfe535d6', 3);
INSERT INTO uzytkownicy (id, login, haslo, id_uprawnienia) VALUES (17, 'test4', 'scrypt:32768:8:1$CxPR5wqll2KCyAnV$c949ff17656f0670f4e5481bdac31df6208300a7c2b3026f9084b0cda63084d5edb68432fbc20860e6c73b3658987d8e1bf90bbb03d7f244d6012c0732702d52', 3);
INSERT INTO uzytkownicy (id, login, haslo, id_uprawnienia) VALUES (18, 'test5', 'scrypt:32768:8:1$4eDliViPVPlYpIXr$884ee3ef0ad8856a916d4eb1f1be758453a29a83634d5d416a107d4e4bcb5217f37f46f08c74fe5215ccc88dbe76ecc45fe898cb7bbc3423cd82deb48e77249c', 2);

-- Dane z tabeli tasma
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (7, '1111-11-11', 1.00, 2.00, 5.00, 0.00, '11', '11', '11', '111', '0001-11-11', 1, 1, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (8, '2025-02-13', 1.00, 1.00, 321.00, 0.00, '8', '8', '8', '8', '2025-02-20', 1, 2, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (9, '2025-02-22', 1.00, 1.00, 34.00, 0.00, '1', '1', '11111', '11111111', '0011-11-11', 1, 2, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (10, '2025-02-22', 1.00, 1.00, 213.00, 0.00, '1', '1', '11111', '11111111', '0011-11-11', 1, 1, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (11, '0111-11-11', 1.00, 1.00, 11.00, 0.00, '111', '1111', '11111', '1111111', '0111-11-11', 1, 2, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (12, '0111-11-11', 1.00, 1.00, 11.00, 0.00, '111', '1111', '11111', '1111111', '0111-11-11', 1, 2, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (13, '0011-11-21', 1.00, 2.00, 111.00, 0.00, '11', '1111', '1111', '1111', '0001-11-11', 1, 1, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (14, '0011-11-11', 1.00, 2.00, 1.00, 0.00, '11', '111', '11', '13', '0003-03-31', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (15, '0001-11-11', 1.00, 1.00, 123.00, 0.00, '3123', '213', '213', '123123', '0003-03-12', 1, 3, 3);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (16, '0231-02-13', 1.00, 1.00, 213123.00, 0.00, '213123', '213213', '2131312', '213213', '0002-03-21', 1, 2, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (17, '0012-03-12', 1.00, 1.00, 213.00, 0.00, '312312', '123213123', '123213123', '1321312', '0123-03-12', 1, 2, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (18, '0012-12-12', 1.00, 1.00, 1212.00, 0.00, '1212', '121212', '12121', '121212', '0012-12-12', 1, 1, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (19, '0123-03-12', 1.00, 2.00, 123123.00, 0.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (20, '0123-03-12', 1.00, 2.00, 123123.00, 0.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (21, '0123-03-12', 1.00, 2.00, 123123.00, 0.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (22, '0123-03-12', 1.00, 2.00, 123123.00, 0.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (23, '0123-03-12', 1.00, 2.00, 123123.00, 0.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (24, '0123-03-12', 1.00, 2.00, 123123.00, 0.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (25, '3123-03-12', 1.00, 2.00, 123123.00, 0.00, '2312313', '2313123', '1312313', '21312312', '0023-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (26, '3123-03-12', 1.00, 2.00, 123123.00, 0.00, '2312313', '2313123', '1312313', '21312312ttt', '0023-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (27, '0002-12-12', 1.00, 1.00, 23123.00, 0.00, '12313', '123312', '123123', '123213', '0213-03-12', 1, 1, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (28, '2222-02-22', 1.00, 1.00, 99999999.99, 0.00, '2222222222', '2', '2', '2', '2222-02-22', 14, 1, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (29, '0002-02-22', 1.00, 2.00, 22.00, 0.00, '22', '222', '222', '222', '0002-02-22', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (30, '0002-02-22', 1.00, 2.00, 22.00, 0.00, '22', '222', '222', '222', '0002-02-22', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (31, '0002-02-22', 1.00, 2.00, 22.00, 0.00, '22', '222', '222', '222', '0002-02-22', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (32, '1231-03-21', 1.00, 1.00, 132213.00, 0.00, '123123', '123123213123', '12312312312312', '1231231231', '0023-03-12', 1, 1, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (33, '0011-11-11', 1.00, 66.00, 1223.00, 0.00, '23', '23', '43', '324', '0034-03-31', 1, 3, 3);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (34, '0123-03-21', 8.20, 8.10, 12312.00, 0.00, '312312', '123', '132', '123', '0312-03-12', 1, 4, 8);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (35, '0003-03-12', 0.00, 0.00, 21.00, 0.00, 'teeeeee', 'rt', '213', '123', '0123-03-12', 1, 1, 4);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (36, '2333-03-23', 4.00, 4.00, 6.00, 0.00, '132', '213', '123', '231', '0333-03-21', 1, 1, 9);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (37, '0033-02-13', 1.00, 66.00, 213.00, 0.00, '123', '312', '321', '123', '3333-03-12', 1, 1, 3);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (38, '0003-03-12', 1.00, 2.00, 5.00, 2.00, '213', '213', '321', '321', '0333-12-23', 1, 1, 1);

-- Dane z tabeli profil
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (9, 14, '2025-02-26', 12:06:36, 12:06:43, 3.00, '1212', '1212', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (10, 7, '2025-03-02', 13:03:47, 13:04:13, 6.00, '34', 'dawo', 14);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (11, 7, '2025-03-02', 13:04:48, 13:04:54, 5.00, '66', '666', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (12, 8, '2025-03-14', 18:11:29, 18:11:35, 32.00, '213', '213', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (13, 10, '2025-03-14', 18:30:21, 18:30:24, 231.00, '123', '123', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (14, 35, '2025-03-14', 18:31:45, 18:32:00, 21.00, '231', '123', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (15, 9, '2025-03-25', 14:01:43, 14:01:47, 2.00, '123', '213', 16);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (16, 10, '2025-03-24', 14:02:06, 14:02:10, 213.00, '123', '213', 16);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (17, 8, '2025-03-24', 14:03:48, 14:03:52, 213.00, '123', '132', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (18, 9, '2025-03-26', 14:16:49, 14:16:53, 34.00, '432', '324', 16);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (19, 8, '2025-03-26', 14:47:19, 14:47:24, 321.00, '321', '321', 16);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (20, 36, '2025-03-27', 12:22:20, 12:22:28, 6.00, '56', '65', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (21, 38, '2025-03-27', 13:56:57, 13:57:09, 5.00, '123', '231', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (22, 38, '2025-03-27', 13:59:22, 13:59:33, 2.00, '21', '21', 1);

