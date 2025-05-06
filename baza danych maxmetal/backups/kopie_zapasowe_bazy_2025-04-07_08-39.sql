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
  `lokalizacja` varchar(255) NOT NULL,
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
  CONSTRAINT `fk_tasma_dostawca` FOREIGN KEY (`dostawca_id`) REFERENCES `dostawcy` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tasma_pracownik` FOREIGN KEY (`pracownik_id`) REFERENCES `uzytkownicy` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_tasma_szablon` FOREIGN KEY (`szablon_id`) REFERENCES `szablon` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Struktura tabeli `profil`
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
  `Data_do_usuwania` date NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `id_tasmy` (`id_tasmy`),
  KEY `id_pracownika` (`id_pracownika`),
  CONSTRAINT `profil_ibfk_1` FOREIGN KEY (`id_tasmy`) REFERENCES `tasma` (`id`) ON DELETE CASCADE,
  CONSTRAINT `profil_ibfk_2` FOREIGN KEY (`id_pracownika`) REFERENCES `uzytkownicy` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dane z tabeli `uprawnienia`
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES (1, 'Administrator');
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES (2, 'Zaopatrzeniowiec ');
INSERT INTO `uprawnienia` (id_uprawnienia, nazwa) VALUES (3, 'Pracownik');

-- Dane z tabeli `uzytkownicy`
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES (1, 'Administrator', 'scrypt:32768:8:1$hFji6Y2E4ieYI6Bp$d019011fb8ea6f21b31c18f54dbbf95f664ed512a7ffc0bb4a2a9b28b709e5fd7b5766675d7a7223aacc24bfdae9b038c22d61f6a1d00a212611c80e068ec153', 1);
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES (14, 'test1', 'scrypt:32768:8:1$g85jfiQGw8D1zVS1$61a4ed4d2ef9a2530b54939d1d472b43b61348c7c11ce5861e434799ec28999ac8e0373060f41d3b0e32e867794e839fa270277770a5f81e451aaf500c15109b', 1);
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES (16, 'test3', 'scrypt:32768:8:1$3zFtfjuCE2ekzMrt$9b1fa256e8c9b2e762949d17a45b6cfe2d544ea726da11fc7688676321ca63c029939ff18cba7b299e6d49f7029875c427282243b6078fbdb29e3de9dfe535d6', 3);
INSERT INTO `uzytkownicy` (id, login, haslo, id_uprawnienia) VALUES (17, 'test4', 'scrypt:32768:8:1$t3iQxJMK4QQE0eJg$d901c7265ccbf9c12a42dc7dab5974da829e86641ccafc6629e51588cd82db1235c61b3c6ab2ed648fc16c1ad0d1c300f1925f283b9124c78bd1c1eee33f5ed2', 1);

-- Dane z tabeli `dostawcy`
INSERT INTO `dostawcy` (id, nazwa) VALUES (1, 'dostawca1');
INSERT INTO `dostawcy` (id, nazwa) VALUES (2, 'dostawca2');
INSERT INTO `dostawcy` (id, nazwa) VALUES (5, 'nic');
INSERT INTO `dostawcy` (id, nazwa) VALUES (3, 'test1');
INSERT INTO `dostawcy` (id, nazwa) VALUES (4, 'ttttttr');

-- Dane z tabeli `szablon`
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES (1, 'Dx2', 'D', 'x', 77.00, 3.00);
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES (2, 'TT', 't', 'r', 1.00, 1.00);
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES (3, 'DX510 2275 1,2x66', 'DX510', '2275', 1.00, 66.00);
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES (4, 'ww ww wwxww', 'ww', 'ww', 0.00, 0.00);
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES (5, '22 22 TruexTrue', '22', '22', 1.00, 1.00);
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES (6, 't t TruexTrue', 't', 't', 1.00, 1.00);
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES (7, '11 11 11x11', '11', '11', 11.00, 11.00);
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES (8, '121 122 8.1x8.2', '121', '122', 8.20, 8.10);
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES (9, 'ttr 4ewr 4,2x4', 'ttr', '4ewr', 4.20, 4.00);
INSERT INTO `szablon` (id, nazwa, rodzaj, grubosc_i_oznaczenie_ocynku, grubosc, szerokosc) VALUES (10, 'ttr20 mc4 4x5', 'ttr20', 'mc4', 5.00, 4.00);

-- Dane z tabeli `tasma`
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (9, '2025-02-22', 1.00, 1.00, 34.00, 0.00, '1', '1', '11111', '11111111', '0011-11-11', 1, 2, 2, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (10, '2025-02-22', 1.00, 1.00, 213.00, 0.00, '1', '1', '11111', '11111111', '0011-11-11', 1, 1, 2, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (11, '0111-11-11', 1.00, 1.00, 11.00, 0.00, '111', '1111', '11111', '1111111', '0111-11-11', 1, 2, 2, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (12, '0111-11-11', 1.00, 1.00, 11.00, 0.00, '111', '1111', '11111', '1111111', '0111-11-11', 1, 2, 2, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (13, '0456-07-07', 77.00, 3.00, 111.00, 0.00, '11', '1111', '1111', '1111', '0001-11-11', 1, 1, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (14, '0011-11-11', 77.00, 3.00, 1.00, 0.00, '11', '111', '11', '13', '0003-03-31', 1, 2, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (15, '0001-11-11', 1.00, 1.00, 123.00, 0.00, '3123', '213', '213', '123123', '0003-03-12', 1, 3, 3, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (16, '0231-02-13', 1.00, 1.00, 213123.00, 0.00, '213123', '213213', '2131312', '213213', '0002-03-21', 1, 2, 2, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (17, '0012-03-12', 1.00, 1.00, 213.00, 0.00, '312312', '123213123', '123213123', '1321312', '0123-03-12', 1, 2, 2, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (18, '0012-12-12', 1.00, 1.00, 1212.00, 0.00, '1212', '121212', '12121', '121212', '0012-12-12', 1, 1, 2, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (19, '0123-03-12', 77.00, 3.00, 123123.00, 0.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (20, '0123-03-12', 77.00, 3.00, 123123.00, 0.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (21, '0123-03-12', 77.00, 3.00, 123123.00, 0.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (22, '0123-03-12', 77.00, 3.00, 123123.00, 0.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (23, '0123-03-12', 77.00, 3.00, 123123.00, 0.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (24, '0123-03-12', 77.00, 3.00, 123123.00, 0.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (25, '3123-03-12', 77.00, 3.00, 123123.00, 0.00, '2312313', '2313123', '1312313', '21312312', '0023-03-12', 1, 2, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (26, '3123-03-12', 77.00, 3.00, 123123.00, 0.00, '2312313', '2313123', '1312313', '21312312ttt', '0023-03-12', 1, 2, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (27, '0002-12-12', 1.00, 1.00, 23123.00, 0.00, '12313', '123312', '123123', '123213', '0213-03-12', 1, 1, 2, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (28, '2222-02-22', 1.00, 1.00, 99999999.99, 0.00, '2222222222', '2', '2', '2', '2222-02-22', 14, 1, 2, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (29, '0002-02-22', 77.00, 3.00, 22.00, 0.00, '22', '222', '222', '222', '0002-02-22', 1, 2, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (30, '0002-02-22', 77.00, 3.00, 22.00, 0.00, '22', '222', '222', '222', '0002-02-22', 1, 2, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (31, '0002-02-22', 77.00, 3.00, 22.00, 0.00, '22', '222', '222', '222', '0002-02-22', 1, 2, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (32, '1231-03-21', 1.00, 1.00, 132213.00, 0.00, '123123', '123123213123', '12312312312312', '1231231231', '0023-03-12', 1, 1, 2, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (33, '0011-11-11', 1.00, 66.00, 1223.00, 0.00, '23', '23', '43', '324', '0034-03-31', 1, 3, 3, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (34, '0123-03-21', 8.20, 8.10, 12312.00, 0.00, '312312', '123', '132', '123', '0312-03-12', 1, 4, 8, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (36, '2333-03-23', 4.20, 4.00, 6.00, 0.00, '132', '213', '123', '231', '0333-03-21', 1, 1, 9, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (37, '0033-02-13', 77.00, 3.00, 213.00, 0.00, '123', '31222', '321', '123', '3333-03-12', 1, 1, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (38, '0003-03-12', 8.20, 8.10, 5.00, 1.00, '213', '213', '321', '3212', '0333-12-23', 1, 1, 8, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (39, '0033-12-31', 0.00, 0.00, 3213.00, 1.00, '13123', '3123', '132', '123', '0321-03-12', NULL, 3, 4, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (40, '0033-12-31', 77.00, 3.00, 3213.00, 123.00, '13123', '3123', '132', '123', '0321-03-12', NULL, 1, 1, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (41, '6564-04-06', 0.00, 0.00, 456456.00, 0.00, '456456', '45645', '6546456', '456456', '4564-06-04', 1, 4, 4, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (42, '0011-11-11', 0.00, 0.00, 111.00, 3.00, '11', '111', '1111', '1111', '0001-11-11', 1, 2, 4, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (43, '0011-11-11', 0.00, 0.00, 111.00, 10.00, '11', '111`12`', '1111', '1111', '0001-11-11', 1, 1, 4, '2025-04-06');
INSERT INTO `tasma` (id, data_z_etykiety_na_kregu, grubosc, szerokosc, waga_kregu, waga_kregu_na_stanie, nr_etykieta_paletowa, nr_z_etykiety_na_kregu, lokalizacja, nr_faktury_dostawcy, data_dostawy, pracownik_id, dostawca_id, szablon_id, Data_do_usuwania) VALUES (44, '0213-12-12', 1.00, 1.00, 213.00, 213.00, '123', '123123', '123123', '23132', '3123-03-12', 1, 1, 5, '2025-04-06');

-- Dane z tabeli `profil`
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (13, 10, '2025-03-14', '18:30:21', 18:30:24, 231.00, '123', '123', 1, '2025-04-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (15, 9, '2025-03-25',  '14:01:43', 14:01:47, 2.00, '123', '213', 16, '2025-04-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (16, 10, '2025-03-24', '14:02:06', 14:02:10, 213.00, '123', '213', 16, '2025-04-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (18, 9, '2025-03-26',  '14:16:49', 14:16:53, 34.00, '432', '324', 16, '2025-04-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (20, 36, '2025-03-27', '12:22:20', 12:22:28, 6.00, '56', '65', 1, '2025-04-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (21, 37, '0003-03-27', '3:33:57', 23:03:09, 231.00, '123213', '23123', 1, '2025-04-01');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (23, 38, '0066-05-06', '11:31:37', 11:31:45, 1.00, '23', '777', 17, '2025-04-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (24, 41, '2025-03-28', '12:27:47', 12:27:59, 10.30, '665333', '56658', 1, '2025-04-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (27, 41, '2025-04-04', '16:16:55', 16:17:25, 0.00, '5', '5', 1, '2025-04-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (28, 39, '2025-04-04', '16:20:36', 16:21:11, 5.00, '7', '543', 17, '2025-04-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (29, 43, '2025-04-05', '16:09:21', 16:10:45, 10.00, '34', 'tt', 14, '2025-04-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (30, 42, '2025-04-06', '17:44:09', 17:44:14, 3.00, '123', '123', 1, '2025-04-06');
INSERT INTO `profil` (id, id_tasmy, data_produkcji, godz_min_rozpoczecia, godz_min_zakonczenia, zwrot_na_magazyn_kg, nr_czesci_klienta, nazwa_klienta_nr_zlecenia_PRODIO, id_pracownika, Data_do_usuwania) VALUES (32, 39, '2025-04-06', '20:08:37', 20:08:42, 1.00, '6', '2', 1, '2026-04-06');


SET FOREIGN_KEY_CHECKS = 1;
