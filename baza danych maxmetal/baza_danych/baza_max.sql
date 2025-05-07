-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Maj 07, 2025 at 02:14 PM
-- Wersja serwera: 10.4.32-MariaDB
-- Wersja PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `baza_max`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `dlugosci`
--

CREATE TABLE `dlugosci` (
  `id` int(11) NOT NULL,
  `nazwa` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dlugosci`
--

INSERT INTO `dlugosci` (`id`, `nazwa`) VALUES
(1, '1'),
(2, '2'),
(5, '2.5'),
(3, '3'),
(4, '4'),
(6, '5');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `dostawcy`
--

CREATE TABLE `dostawcy` (
  `id` int(11) NOT NULL,
  `nazwa` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dostawcy`
--

INSERT INTO `dostawcy` (`id`, `nazwa`) VALUES
(1, 'dostawca1'),
(2, 'dostawca2'),
(5, 'nic'),
(3, 'test1'),
(4, 'ttttttr6');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `ksztaltowanie`
--

CREATE TABLE `ksztaltowanie` (
  `id` int(11) NOT NULL,
  `rozmiar` varchar(255) DEFAULT NULL,
  `data` date DEFAULT NULL,
  `godzina_rozpoczecia` time DEFAULT NULL,
  `godzina_zakonczenia` time DEFAULT NULL,
  `ilosc` int(11) DEFAULT NULL,
  `ilosc_na_stanie` int(11) DEFAULT NULL,
  `nr_prodio` varchar(100) DEFAULT NULL,
  `id_materialu` int(11) DEFAULT NULL,
  `id_pracownik` int(11) DEFAULT NULL,
  `imie_nazwisko` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `laczenie`
--

CREATE TABLE `laczenie` (
  `id` int(11) NOT NULL,
  `id_zlecenie` int(11) DEFAULT NULL,
  `id_powrot` int(11) DEFAULT NULL,
  `ile_sztuk` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `lokalizacja`
--

CREATE TABLE `lokalizacja` (
  `id` int(11) NOT NULL,
  `nazwa` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `lokalizacja`
--

INSERT INTO `lokalizacja` (`id`, `nazwa`) VALUES
(1, 'Magazyn11');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `malarnia`
--

CREATE TABLE `malarnia` (
  `id` int(11) NOT NULL,
  `id_ksztaltowanie` int(11) DEFAULT NULL,
  `ilosc` int(11) DEFAULT NULL,
  `ilosc_na_stanie` int(11) DEFAULT NULL,
  `nr_prodio` varchar(100) DEFAULT NULL,
  `data` date DEFAULT NULL,
  `id_pracownik` int(11) DEFAULT NULL,
  `imie_nazwisko` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `material_obejma`
--

CREATE TABLE `material_obejma` (
  `id` int(11) NOT NULL,
  `certyfikat` varchar(255) DEFAULT NULL,
  `data_dostawy` date DEFAULT NULL,
  `nr_wytopu` varchar(100) DEFAULT NULL,
  `nr_prodio` varchar(100) DEFAULT NULL,
  `ilosc_sztuk` int(11) DEFAULT NULL,
  `ilosc_sztuk_na_stanie` int(11) DEFAULT NULL,
  `id_rozmiaru` int(11) DEFAULT NULL,
  `id_pracownik` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `powrot`
--

CREATE TABLE `powrot` (
  `id` int(11) NOT NULL,
  `data` date DEFAULT NULL,
  `ilosc` int(11) DEFAULT NULL,
  `ilosc_na_stanie` int(11) DEFAULT NULL,
  `nr_prodio` varchar(100) DEFAULT NULL,
  `id_malowania` int(11) DEFAULT NULL,
  `id_pracownik` int(11) DEFAULT NULL,
  `imie_nazwisko` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `profil`
--

CREATE TABLE `profil` (
  `id` int(11) NOT NULL,
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
  `Data_do_usuwania` date DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `profil`
--

INSERT INTO `profil` (`id`, `id_tasmy`, `data_produkcji`, `godz_min_rozpoczecia`, `godz_min_zakonczenia`, `zwrot_na_magazyn_kg`, `id_szablon_profile`, `nazwa_klienta_nr_zlecenia_PRODIO`, `ilosc`, `ilosc_na_stanie`, `id_dlugosci`, `id_pracownika`, `Imie_nazwisko_pracownika`, `Data_do_usuwania`) VALUES
(65, 52, '2025-04-28', '19:16:29', '19:16:44', 3.00, 3, '3422', 243, 243, 1, 1, '432', '2026-04-28'),
(66, 52, '2025-04-28', '19:16:33', '19:16:50', 2.00, 3, '432', 34, 34, 1, 1, '234', '2026-04-28'),
(67, 52, '2025-04-28', '19:17:32', '20:42:55', 0.00, 3, '1', 567, 567, 5, 19, '1', '2026-04-28'),
(68, 52, '2025-04-28', '20:42:33', '20:42:47', 1.00, 3, '453', 534, 534, 5, 1, '543', '2026-04-28'),
(69, 53, '2025-04-28', '20:43:31', '20:44:07', 0.00, 3, '64', 342, 342, 6, 1, '6', '2026-04-28'),
(70, 54, '2025-05-06', '12:28:55', '12:29:15', 111.00, 3, '213', 11, 11, 1, 1, '213', '2026-05-06'),
(71, 54, '2025-05-06', '12:48:34', '12:48:45', 1.00, 3, '213', 123, 123, 1, 19, '123', '2026-05-06'),
(72, 55, '2025-05-06', '14:45:40', '14:48:29', 0.00, 3, '7', 1, 1, 1, 1, '7', '2026-05-06'),
(73, 55, '2025-05-06', '14:51:25', '14:51:50', 0.00, 3, '76', 1, 1, 1, 1, '567', '2026-05-06'),
(74, 55, '2025-05-06', '15:34:12', '15:35:22', 59.02, 4, '6', 1, 1, 1, 1, '6', '2026-05-06'),
(75, 54, '2025-05-07', '12:06:21', NULL, NULL, 3, '45334', NULL, NULL, NULL, 1, '534543', '2026-05-07');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `rozmiary_obejm`
--

CREATE TABLE `rozmiary_obejm` (
  `id` int(11) NOT NULL,
  `nazwa` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `szablon`
--

CREATE TABLE `szablon` (
  `id` int(11) NOT NULL,
  `nazwa` varchar(255) NOT NULL,
  `rodzaj` varchar(255) NOT NULL,
  `grubosc_i_oznaczenie_ocynku` varchar(255) NOT NULL,
  `grubosc` decimal(10,2) NOT NULL,
  `szerokosc` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `szablon`
--

INSERT INTO `szablon` (`id`, `nazwa`, `rodzaj`, `grubosc_i_oznaczenie_ocynku`, `grubosc`, `szerokosc`) VALUES
(1, 'Dx2', 'D', 'x', 77.00, 3.00),
(2, 'TT', 't', 'r', 1.00, 1.00),
(3, 'DX510 2275 1,2x66', 'DX510', '2275', 1.52, 77.00),
(4, 'ww ww wwxww', 'ww', 'ww', 0.00, 0.00),
(5, '22 22 TruexTrue', '22', '22', 1.00, 1.00),
(6, 't t TruexTrue', 't', 't', 1.00, 1.00),
(7, '11 11 11x11', '11', '11', 11.00, 11.00),
(8, '121 122 8.1x8.2', '121', '122', 8.20, 8.10),
(9, 'ttr 4ewr 4,2x4', 'ttr', '4ewr', 4.20, 4.00),
(10, 'ttr20 mc4 4x5', 'ttr20', 'mc4', 5.00, 4.00);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `szablon_profile`
--

CREATE TABLE `szablon_profile` (
  `id` int(11) NOT NULL,
  `nazwa` varchar(255) NOT NULL,
  `waga_w_kg_na_1_metr` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `szablon_profile`
--

INSERT INTO `szablon_profile` (`id`, `nazwa`, `waga_w_kg_na_1_metr`) VALUES
(3, '1235', 7.00),
(4, 'fdgdfhdfgs', 6.98);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tasma`
--

CREATE TABLE `tasma` (
  `id` int(11) NOT NULL,
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
  `Data_do_usuwania` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasma`
--

INSERT INTO `tasma` (`id`, `data_z_etykiety_na_kregu`, `grubosc`, `szerokosc`, `waga_kregu`, `waga_kregu_na_stanie`, `nr_etykieta_paletowa`, `nr_z_etykiety_na_kregu`, `lokalizacja_id`, `nr_faktury_dostawcy`, `data_dostawy`, `pracownik_id`, `dostawca_id`, `szablon_id`, `Data_do_usuwania`) VALUES
(51, '0023-03-31', 1.52, 77.00, 23.00, 0.00, '23', '23', 1, '32', '0002-03-22', 1, 1, 3, '2026-04-27'),
(52, '0033-03-21', 0.00, 0.00, 132.00, 0.00, '321', '321', 1, '213', '0123-03-21', 1, 2, 4, '2026-04-27'),
(53, '2025-06-25', 0.00, 0.00, 5.00, 0.00, '5', '4', 1, '15472', '2025-04-25', 1, 1, 4, '2026-04-28'),
(54, '0576-06-07', 0.00, 0.00, 765.00, 1.00, '756', '756', 1, '576', '0006-05-07', 1, 5, 4, '2026-04-28'),
(55, '2025-08-08', 1.52, 77.00, 324.00, 59.02, '342', '234', 1, '234', '0434-04-04', 20, 1, 3, '2026-05-06');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `uprawnienia`
--

CREATE TABLE `uprawnienia` (
  `id_uprawnienia` int(11) NOT NULL,
  `nazwa` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `uprawnienia`
--

INSERT INTO `uprawnienia` (`id_uprawnienia`, `nazwa`) VALUES
(1, 'Administrator'),
(2, 'Zaopatrzeniowiec '),
(3, 'Pracownik');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `uzytkownicy`
--

CREATE TABLE `uzytkownicy` (
  `id` int(11) NOT NULL,
  `login` text DEFAULT NULL,
  `haslo` text NOT NULL,
  `id_uprawnienia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `uzytkownicy`
--

INSERT INTO `uzytkownicy` (`id`, `login`, `haslo`, `id_uprawnienia`) VALUES
(1, 'Administrator', 'scrypt:32768:8:1$UCBwCJVWPxR43fNh$e822900a3b12c3c4ac274af1701eedd757ba770bba15d8994d2814684fceaed06db771d8ed214e75ec9cb2d9a95ccf7e01b3c4f49bc407c52fe141547a91077b', 1),
(19, 'test4', 'scrypt:32768:8:1$PQ2il1l6Nw5XvM6y$479d92f3fc6f1591c8ec89c249807369991b49827a039f9bcb4f841030184161ce2d46db35dbb843c37ddd053810ea62ba86537261cb853bd8952714ee48a1fa', 3),
(20, 'test5', 'scrypt:32768:8:1$dNUmTnd7ZwVAjUJx$4e6e57c0802dc3bb5b6d73f051003d51aeb022f920954ceabd89cfd982bc795d86a1549a49ffc6bfdea1eedd444884d45467a94d46e118dd7bc162d9ab90ea41', 1);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `zlecenie`
--

CREATE TABLE `zlecenie` (
  `id` int(11) NOT NULL,
  `nr_zamowienia_zew` varchar(100) DEFAULT NULL,
  `nr_prodio` varchar(100) DEFAULT NULL,
  `ile_pianki` int(11) DEFAULT NULL,
  `seria_tasmy` varchar(100) DEFAULT NULL,
  `ile_tasmy` int(11) DEFAULT NULL,
  `nr_kartonu` varchar(100) DEFAULT NULL,
  `id_pracownik` int(11) DEFAULT NULL,
  `imie_nazwisko` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `dlugosci`
--
ALTER TABLE `dlugosci`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nazwa` (`nazwa`);

--
-- Indeksy dla tabeli `dostawcy`
--
ALTER TABLE `dostawcy`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nazwa` (`nazwa`);

--
-- Indeksy dla tabeli `ksztaltowanie`
--
ALTER TABLE `ksztaltowanie`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_materialu` (`id_materialu`),
  ADD KEY `id_pracownik` (`id_pracownik`);

--
-- Indeksy dla tabeli `laczenie`
--
ALTER TABLE `laczenie`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_zlecenie` (`id_zlecenie`),
  ADD KEY `id_powrot` (`id_powrot`);

--
-- Indeksy dla tabeli `lokalizacja`
--
ALTER TABLE `lokalizacja`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `malarnia`
--
ALTER TABLE `malarnia`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_ksztaltowanie` (`id_ksztaltowanie`),
  ADD KEY `id_pracownik` (`id_pracownik`);

--
-- Indeksy dla tabeli `material_obejma`
--
ALTER TABLE `material_obejma`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_rozmiaru` (`id_rozmiaru`),
  ADD KEY `id_pracownik` (`id_pracownik`);

--
-- Indeksy dla tabeli `powrot`
--
ALTER TABLE `powrot`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_malowania` (`id_malowania`),
  ADD KEY `id_pracownik` (`id_pracownik`);

--
-- Indeksy dla tabeli `profil`
--
ALTER TABLE `profil`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_tasmy` (`id_tasmy`),
  ADD KEY `id_pracownika` (`id_pracownika`),
  ADD KEY `profil_ibfk_3` (`id_dlugosci`),
  ADD KEY `profil_ibfk_4` (`id_szablon_profile`);

--
-- Indeksy dla tabeli `rozmiary_obejm`
--
ALTER TABLE `rozmiary_obejm`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `szablon`
--
ALTER TABLE `szablon`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nazwa` (`nazwa`);

--
-- Indeksy dla tabeli `szablon_profile`
--
ALTER TABLE `szablon_profile`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `tasma`
--
ALTER TABLE `tasma`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_tasma_pracownik` (`pracownik_id`),
  ADD KEY `fk_tasma_dostawca` (`dostawca_id`),
  ADD KEY `fk_tasma_szablon` (`szablon_id`),
  ADD KEY `fk_tasma_lokalizacja` (`lokalizacja_id`);

--
-- Indeksy dla tabeli `uprawnienia`
--
ALTER TABLE `uprawnienia`
  ADD PRIMARY KEY (`id_uprawnienia`);

--
-- Indeksy dla tabeli `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_uzytkownicy_uprawnienia` (`id_uprawnienia`);

--
-- Indeksy dla tabeli `zlecenie`
--
ALTER TABLE `zlecenie`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_pracownik` (`id_pracownik`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `dlugosci`
--
ALTER TABLE `dlugosci`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `dostawcy`
--
ALTER TABLE `dostawcy`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `ksztaltowanie`
--
ALTER TABLE `ksztaltowanie`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `laczenie`
--
ALTER TABLE `laczenie`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lokalizacja`
--
ALTER TABLE `lokalizacja`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `malarnia`
--
ALTER TABLE `malarnia`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `material_obejma`
--
ALTER TABLE `material_obejma`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `powrot`
--
ALTER TABLE `powrot`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `profil`
--
ALTER TABLE `profil`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;

--
-- AUTO_INCREMENT for table `rozmiary_obejm`
--
ALTER TABLE `rozmiary_obejm`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `szablon`
--
ALTER TABLE `szablon`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `szablon_profile`
--
ALTER TABLE `szablon_profile`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `tasma`
--
ALTER TABLE `tasma`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT for table `uprawnienia`
--
ALTER TABLE `uprawnienia`
  MODIFY `id_uprawnienia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `zlecenie`
--
ALTER TABLE `zlecenie`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `ksztaltowanie`
--
ALTER TABLE `ksztaltowanie`
  ADD CONSTRAINT `ksztaltowanie_ibfk_1` FOREIGN KEY (`id_materialu`) REFERENCES `material_obejma` (`id`),
  ADD CONSTRAINT `ksztaltowanie_ibfk_2` FOREIGN KEY (`id_pracownik`) REFERENCES `uzytkownicy` (`id`);

--
-- Constraints for table `laczenie`
--
ALTER TABLE `laczenie`
  ADD CONSTRAINT `laczenie_ibfk_1` FOREIGN KEY (`id_zlecenie`) REFERENCES `zlecenie` (`id`),
  ADD CONSTRAINT `laczenie_ibfk_2` FOREIGN KEY (`id_powrot`) REFERENCES `powrot` (`id`);

--
-- Constraints for table `malarnia`
--
ALTER TABLE `malarnia`
  ADD CONSTRAINT `malarnia_ibfk_1` FOREIGN KEY (`id_ksztaltowanie`) REFERENCES `ksztaltowanie` (`id`),
  ADD CONSTRAINT `malarnia_ibfk_2` FOREIGN KEY (`id_pracownik`) REFERENCES `uzytkownicy` (`id`);

--
-- Constraints for table `material_obejma`
--
ALTER TABLE `material_obejma`
  ADD CONSTRAINT `material_obejma_ibfk_1` FOREIGN KEY (`id_rozmiaru`) REFERENCES `rozmiary_obejm` (`id`),
  ADD CONSTRAINT `material_obejma_ibfk_2` FOREIGN KEY (`id_pracownik`) REFERENCES `uzytkownicy` (`id`);

--
-- Constraints for table `powrot`
--
ALTER TABLE `powrot`
  ADD CONSTRAINT `powrot_ibfk_1` FOREIGN KEY (`id_malowania`) REFERENCES `malarnia` (`id`),
  ADD CONSTRAINT `powrot_ibfk_2` FOREIGN KEY (`id_pracownik`) REFERENCES `uzytkownicy` (`id`);

--
-- Constraints for table `profil`
--
ALTER TABLE `profil`
  ADD CONSTRAINT `profil_ibfk_1` FOREIGN KEY (`id_tasmy`) REFERENCES `tasma` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `profil_ibfk_2` FOREIGN KEY (`id_pracownika`) REFERENCES `uzytkownicy` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `profil_ibfk_3` FOREIGN KEY (`id_dlugosci`) REFERENCES `dlugosci` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `profil_ibfk_4` FOREIGN KEY (`id_szablon_profile`) REFERENCES `szablon_profile` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tasma`
--
ALTER TABLE `tasma`
  ADD CONSTRAINT `fk_tasma_dostawca` FOREIGN KEY (`dostawca_id`) REFERENCES `dostawcy` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tasma_lokalizacja` FOREIGN KEY (`lokalizacja_id`) REFERENCES `lokalizacja` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_tasma_pracownik` FOREIGN KEY (`pracownik_id`) REFERENCES `uzytkownicy` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tasma_szablon` FOREIGN KEY (`szablon_id`) REFERENCES `szablon` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  ADD CONSTRAINT `fk_uzytkownicy_uprawnienia` FOREIGN KEY (`id_uprawnienia`) REFERENCES `uprawnienia` (`id_uprawnienia`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `zlecenie`
--
ALTER TABLE `zlecenie`
  ADD CONSTRAINT `zlecenie_ibfk_1` FOREIGN KEY (`id_pracownik`) REFERENCES `uzytkownicy` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
