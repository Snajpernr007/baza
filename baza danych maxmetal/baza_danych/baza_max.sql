-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 11, 2025 at 10:13 PM
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
-- Struktura tabeli dla tabeli `profil`
--

CREATE TABLE `profil` (
  `id` int(11) NOT NULL,
  `id_tasmy` int(11) NOT NULL,
  `data_produkcji` date NOT NULL,
  `godz_min_rozpoczecia` time NOT NULL,
  `godz_min_zakonczenia` time NOT NULL,
  `zwrot_na_magazyn_kg` decimal(10,2) DEFAULT NULL,
  `nr_czesci_klienta` varchar(50) NOT NULL,
  `nazwa_klienta_nr_zlecenia_PRODIO` varchar(100) DEFAULT NULL,
  `etykieta_klienta` varchar(50) NOT NULL,
  `id_pracownika` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `profil`
--

INSERT INTO `profil` (`id`, `id_tasmy`, `data_produkcji`, `godz_min_rozpoczecia`, `godz_min_zakonczenia`, `zwrot_na_magazyn_kg`, `nr_czesci_klienta`, `nazwa_klienta_nr_zlecenia_PRODIO`, `etykieta_klienta`, `id_pracownika`) VALUES
(1, 3, '2025-02-01', '19:17:51', '19:18:08', 0.00, '4', '7', '0.00', 1),
(2, 2, '2025-02-02', '23:20:57', '23:21:14', 0.00, '6', '6', '6', 1),
(3, 1, '2025-02-02', '23:21:26', '23:21:40', 0.00, '333', '8', '8', 1),
(4, 3, '2025-02-02', '23:21:44', '23:21:50', 3.00, '3', '3', '3', 1),
(5, 1, '2025-02-10', '14:24:21', '14:24:27', 11.00, '11', '11', '11', 1),
(6, 1, '2025-02-10', '14:42:49', '14:42:59', 11.00, '1', '1', '1', 1);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tasma`
--

CREATE TABLE `tasma` (
  `id` int(11) NOT NULL,
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
  `pracownik_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasma`
--

INSERT INTO `tasma` (`id`, `nazwa_dostawcy`, `nazwa_materialu`, `data_z_etykiety_na_kregu`, `grubosc`, `szerokosc`, `waga_kregu`, `nr_etykieta_paletowa`, `nr_z_etykiety_na_kregu`, `lokalizacja`, `nr_faktury_dostawcy`, `data_dostawy`, `pracownik_id`) VALUES
(1, '1', '2025-02-01', '0000-00-00', 19.00, 0.00, 11.00, '4444', '1', '1', '12', '0000-00-00', NULL),
(2, '1', '1', '0001-01-01', 1.00, 1.00, 0.00, '1', '1', '1', '1', '0001-01-01', 1),
(3, '8', '8', '0008-08-08', 8.00, 8.00, 3.00, '4', '8', '8', '8', '0008-08-08', 1),
(4, '2342', '3424', '0034-04-04', 423.00, 234.00, 234.00, '234', '243', '243', '243', '0423-04-23', 1),
(5, '2', '2', '0022-02-22', 22.00, 2.00, 2.00, '2', '2', '22', '2', '0002-02-22', 1);

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
  `imie` text DEFAULT NULL,
  `nazwisko` text DEFAULT NULL,
  `haslo` text NOT NULL,
  `id_uprawnienia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `uzytkownicy`
--

INSERT INTO `uzytkownicy` (`id`, `login`, `imie`, `nazwisko`, `haslo`, `id_uprawnienia`) VALUES
(1, 'Administrator', 'Administrator', 'Administrator', 'scrypt:32768:8:1$hFji6Y2E4ieYI6Bp$d019011fb8ea6f21b31c18f54dbbf95f664ed512a7ffc0bb4a2a9b28b709e5fd7b5766675d7a7223aacc24bfdae9b038c22d61f6a1d00a212611c80e068ec153', 1);

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `profil`
--
ALTER TABLE `profil`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_tasmy` (`id_tasmy`),
  ADD KEY `id_pracownika` (`id_pracownika`);

--
-- Indeksy dla tabeli `tasma`
--
ALTER TABLE `tasma`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_tasma_pracownik` (`pracownik_id`);

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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `profil`
--
ALTER TABLE `profil`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `tasma`
--
ALTER TABLE `tasma`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `uprawnienia`
--
ALTER TABLE `uprawnienia`
  MODIFY `id_uprawnienia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `profil`
--
ALTER TABLE `profil`
  ADD CONSTRAINT `profil_ibfk_1` FOREIGN KEY (`id_tasmy`) REFERENCES `tasma` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `profil_ibfk_2` FOREIGN KEY (`id_pracownika`) REFERENCES `uzytkownicy` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tasma`
--
ALTER TABLE `tasma`
  ADD CONSTRAINT `fk_tasma_pracownik` FOREIGN KEY (`pracownik_id`) REFERENCES `uzytkownicy` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  ADD CONSTRAINT `fk_uzytkownicy_uprawnienia` FOREIGN KEY (`id_uprawnienia`) REFERENCES `uprawnienia` (`id_uprawnienia`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
