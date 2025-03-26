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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `tasma` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  `dostawca_id` int(11) NOT NULL,
  `szablon_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_tasma_pracownik` (`pracownik_id`),
  KEY `fk_tasma_dostawca` (`dostawca_id`),
  KEY `fk_tasma_szablon` (`szablon_id`),
  CONSTRAINT `fk_tasma_dostawca` FOREIGN KEY (`dostawca_id`) REFERENCES `dostawcy` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tasma_pracownik` FOREIGN KEY (`pracownik_id`) REFERENCES `uzytkownicy` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_tasma_szablon` FOREIGN KEY (`szablon_id`) REFERENCES `szablon` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dane z tabeli uprawnienia
INSERT INTO uprawnienia (id_uprawnienia, nazwa) VALUES (1, 'Administrator');
INSERT INTO uprawnienia (id_uprawnienia, nazwa) VALUES (2, 'Zaopatrzeniowiec ');
INSERT INTO uprawnienia (id_uprawnienia, nazwa) VALUES (3, 'Pracownik');

-- Dane z tabeli uzytkownicy
INSERT INTO uzytkownicy (id, login, haslo, id_uprawnienia) VALUES (1, 'Administrator', 'scrypt:32768:8:1$hFji6Y2E4ieYI6Bp$d019011fb8ea6f21b31c18f54dbbf95f664ed512a7ffc0bb4a2a9b28b709e5fd7b5766675d7a7223aacc24bfdae9b038c22d61f6a1d00a212611c80e068ec153', 1);
INSERT INTO uzytkownicy (id, login, haslo, id_uprawnienia) VALUES (14, 'test1', 'scrypt:32768:8:1$FhBeCDCIO9WLa0wi$bc9fe9f869161f96dd5d866f49efb293c30dfa2f194de45bcd6cba2e8c92a3d8a4e427e5b56e922c731b7acc22d9065733c238fff4faac4f099f8741cfcb1b67', 1);
INSERT INTO uzytkownicy (id, login, haslo, id_uprawnienia) VALUES (15, 'test2', 'scrypt:32768:8:1$JvEhFOfGKXFsubtK$93b751d380a48644fc95b961066fcc8acb0506d9efe94cbeca7b4f23449288e383b44240a2ce0a063a2060cdb28be524826a6e6f85a37346c11e6293240e1ee9', 3);
INSERT INTO uzytkownicy (id, login, haslo, id_uprawnienia) VALUES (16, 'test3', 'scrypt:32768:8:1$DohPG9izhS5XSxI2$75dbf613f6e81a6744c351b733eae76f08a079b6767890b02bc8ededdc3adc7b0202c51af3930f2e70dde2ece0451e35b1512e262f55bdb5952827019f014895', 3);

-- Dane z tabeli tasma
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (7, '1111-11-11', 1.00, 2.00, 5.00, '11', '11', '11', '111', '0001-11-11', 1, 1, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (8, '2025-02-13', 1.00, 1.00, 32.00, '8', '8', '8', '8', '2025-02-20', 1, 2, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (9, '2025-02-22', 1.00, 1.00, 1.00, '1', '1', '11111', '11111111', '0011-11-11', 1, 1, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (10, '2025-02-22', 1.00, 1.00, 231.00, '1', '1', '11111', '11111111', '0011-11-11', 1, 1, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (11, '0111-11-11', 1.00, 1.00, 11.00, '111', '1111', '11111', '1111111', '0111-11-11', 1, 2, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (12, '0111-11-11', 1.00, 1.00, 11.00, '111', '1111', '11111', '1111111', '0111-11-11', 1, 2, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (13, '0011-11-21', 1.00, 2.00, 111.00, '11', '1111', '1111', '1111', '0001-11-11', 1, 1, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (14, '0011-11-11', 1.00, 2.00, 1.00, '11', '111', '11', '13', '0003-03-31', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (15, '0001-11-11', 1.00, 1.00, 123.00, '3123', '213', '213', '123123', '0003-03-12', 1, 1, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (16, '0231-02-13', 1.00, 1.00, 213123.00, '213123', '213213', '2131312', '213213', '0002-03-21', 1, 2, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (17, '0012-03-12', 1.00, 1.00, 213.00, '312312', '123213123', '123213123', '1321312', '0123-03-12', 1, 2, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (18, '0012-12-12', 1.00, 1.00, 1212.00, '1212', '121212', '12121', '121212', '0012-12-12', 1, 1, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (19, '0123-03-12', 1.00, 2.00, 123123.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (20, '0123-03-12', 1.00, 2.00, 123123.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (21, '0123-03-12', 1.00, 2.00, 123123.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (22, '0123-03-12', 1.00, 2.00, 123123.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (23, '0123-03-12', 1.00, 2.00, 123123.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (24, '0123-03-12', 1.00, 2.00, 123123.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (25, '3123-03-12', 1.00, 2.00, 123123.00, '2312313', '2313123', '1312313', '21312312', '0023-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (26, '3123-03-12', 1.00, 2.00, 123123.00, '2312313', '2313123', '1312313', '21312312ttt', '0023-03-12', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (27, '0002-12-12', 1.00, 1.00, 23123.00, '12313', '123312', '123123', '123213', '0213-03-12', 1, 1, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (28, '2222-02-22', 1.00, 1.00, 99999999.99, '2222222222', '2', '2', '2', '2222-02-22', 14, 1, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (29, '0002-02-22', 1.00, 2.00, 22.00, '22', '222', '222', '222', '0002-02-22', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (30, '0002-02-22', 1.00, 2.00, 22.00, '22', '222', '222', '222', '0002-02-22', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (31, '0002-02-22', 1.00, 2.00, 22.00, '22', '222', '222', '222', '0002-02-22', 1, 2, 1);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (32, '1231-03-21', 1.00, 1.00, 132213.00, '123123', '123123213123', '12312312312312', '1231231231', '0023-03-12', 1, 1, 2);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (33, '0011-11-11', 1.00, 66.00, 1223.00, '23', '23', '43', '324', '0034-03-31', 1, 3, 3);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (34, '0123-03-21', 8.20, 8.10, 12312.00, '312312', '123', '132', '123', '0312-03-12', 1, 4, 8);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (35, '0003-03-12', 0.00, 0.00, 21.00, 'teeeeee', 'rt', '213', '123', '0123-03-12', 1, 1, 4);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (36, '2333-03-23', 1.00, 66.00, 321.00, '132', '213', '123', '231', '0333-03-21', 1, 2, 3);
INSERT INTO tasma (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id) VALUES (37, '0033-02-13', 1.00, 66.00, 213.00, '123', '312', '321', '123', '3333-03-12', 1, 1, 3);

-- Dane z tabeli profil
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (9, 14, '2025-02-26', 12:06:36, 12:06:43, 3.00, '1212', '1212', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (10, 7, '2025-03-02', 13:03:47, 13:04:13, 6.00, '34', 'dawo', 14);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (11, 7, '2025-03-02', 13:04:48, 13:04:54, 5.00, '66', '666', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (12, 8, '2025-03-14', 18:11:29, 18:11:35, 32.00, '213', '213', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (13, 10, '2025-03-14', 18:30:21, 18:30:24, 231.00, '123', '123', 1);
INSERT INTO profil (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika) VALUES (14, 35, '2025-03-14', 18:31:45, 18:32:00, 21.00, '231', '123', 1);

