-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 14, 2025 at 05:07 PM
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
(3, 'test1'),
(4, 'tttttt');

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
(9, 14, '2025-02-26', '12:06:36', '12:06:43', 1.00, '1212', '1212', '212', 1),
(10, 7, '2025-03-02', '13:03:47', '13:04:13', 6.00, '34', 'dawo', 'h5', 14),
(11, 7, '2025-03-02', '13:04:48', '13:04:54', 5.00, '66', '666', '666', 1);

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
(1, 'Dx2', 'D', 'x', 1.00, 2.00),
(2, 'TT', 't', 'r', 1.00, 1.00),
(3, 'DX510 2275 1,2x66', 'DX510', '2275', 1.00, 66.00),
(4, 'ww ww wwxww', 'ww', 'ww', 0.00, 0.00),
(5, '22 22 TruexTrue', '22', '22', 1.00, 1.00),
(6, 't t TruexTrue', 't', 't', 1.00, 1.00),
(7, '11 11 11x11', '11', '11', 11.00, 11.00),
(8, '12 12 8.1x8.2', '12', '12', 8.20, 8.10);

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
  `nr_etykieta_paletowa` varchar(255) NOT NULL,
  `nr_z_etykiety_na_kregu` varchar(255) NOT NULL,
  `lokalizacja` varchar(255) NOT NULL,
  `nr_faktury_dostawcy` varchar(255) NOT NULL,
  `data_dostawy` date NOT NULL,
  `pracownik_id` int(11) DEFAULT NULL,
  `dostawca_id` int(11) NOT NULL,
  `szablon_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasma`
--

INSERT INTO `tasma` (`id`, `data_z_etykiety_na_kregu`, `grubosc`, `szerokosc`, `waga_kregu`, `nr_etykieta_paletowa`, `nr_z_etykiety_na_kregu`, `lokalizacja`, `nr_faktury_dostawcy`, `data_dostawy`, `pracownik_id`, `dostawca_id`, `szablon_id`) VALUES
(7, '1111-11-11', 1.00, 2.00, 5.00, '11', '11', '11', '111', '0001-11-11', 1, 1, 1),
(8, '2025-02-13', 1.00, 1.00, 8.00, '8', '8', '8', '8', '2025-02-20', 1, 2, 2),
(9, '2025-02-22', 1.00, 1.00, 1.00, '1', '1', '11111', '11111111', '0011-11-11', 1, 1, 2),
(10, '2025-02-22', 1.00, 1.00, 1.00, '1', '1', '11111', '11111111', '0011-11-11', 1, 1, 2),
(11, '0111-11-11', 1.00, 1.00, 11.00, '111', '1111', '11111', '1111111', '0111-11-11', 1, 2, 2),
(12, '0111-11-11', 1.00, 1.00, 11.00, '111', '1111', '11111', '1111111', '0111-11-11', 1, 2, 2),
(13, '0011-11-21', 1.00, 2.00, 111.00, '11', '1111', '1111', '1111', '0001-11-11', 1, 1, 1),
(14, '0011-11-11', 1.00, 2.00, 1.00, '11', '111', '11', '13', '0003-03-31', 1, 2, 1),
(15, '0001-11-11', 1.00, 1.00, 123.00, '3123', '213', '213', '123123', '0003-03-12', 1, 1, 2),
(16, '0231-02-13', 1.00, 1.00, 213123.00, '213123', '213213', '2131312', '213213', '0002-03-21', 1, 2, 2),
(17, '0012-03-12', 1.00, 1.00, 213.00, '312312', '123213123', '123213123', '1321312', '0123-03-12', 1, 2, 2),
(18, '0012-12-12', 1.00, 1.00, 1212.00, '1212', '121212', '12121', '121212', '0012-12-12', 1, 1, 2),
(19, '0123-03-12', 1.00, 2.00, 123123.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1),
(20, '0123-03-12', 1.00, 2.00, 123123.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1),
(21, '0123-03-12', 1.00, 2.00, 123123.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1),
(22, '0123-03-12', 1.00, 2.00, 123123.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1),
(23, '0123-03-12', 1.00, 2.00, 123123.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1),
(24, '0123-03-12', 1.00, 2.00, 123123.00, '123123', '3213', '123', '213', '0122-03-12', 1, 2, 1),
(25, '3123-03-12', 1.00, 2.00, 123123.00, '2312313', '2313123', '1312313', '21312312', '0023-03-12', 1, 2, 1),
(26, '3123-03-12', 1.00, 2.00, 123123.00, '2312313', '2313123', '1312313', '21312312ttt', '0023-03-12', 1, 2, 1),
(27, '0002-12-12', 1.00, 1.00, 23123.00, '12313', '123312', '123123', '123213', '0213-03-12', 1, 1, 2),
(28, '2222-02-22', 1.00, 1.00, 99999999.99, '2222222222', '2', '2', '2', '2222-02-22', 14, 1, 2),
(29, '0002-02-22', 1.00, 2.00, 22.00, '22', '222', '222', '222', '0002-02-22', 1, 2, 1),
(30, '0002-02-22', 1.00, 2.00, 22.00, '22', '222', '222', '222', '0002-02-22', 1, 2, 1),
(31, '0002-02-22', 1.00, 2.00, 22.00, '22', '222', '222', '222', '0002-02-22', 1, 2, 1),
(32, '1231-03-21', 1.00, 1.00, 132213.00, '123123', '123123213123', '12312312312312', '1231231231', '0023-03-12', 1, 1, 2),
(33, '0011-11-11', 1.00, 66.00, 1223.00, '23', '23', '43', '324', '0034-03-31', 1, 3, 3),
(34, '0123-03-21', 8.20, 8.10, 12312.00, '312312', '123', '132', '123', '0312-03-12', 1, 4, 8);

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
(1, 'Administrator', 'Administrator', 'Administrator', 'scrypt:32768:8:1$hFji6Y2E4ieYI6Bp$d019011fb8ea6f21b31c18f54dbbf95f664ed512a7ffc0bb4a2a9b28b709e5fd7b5766675d7a7223aacc24bfdae9b038c22d61f6a1d00a212611c80e068ec153', 1),
(14, 'test1', 'test1', 'test1', 'scrypt:32768:8:1$FhBeCDCIO9WLa0wi$bc9fe9f869161f96dd5d866f49efb293c30dfa2f194de45bcd6cba2e8c92a3d8a4e427e5b56e922c731b7acc22d9065733c238fff4faac4f099f8741cfcb1b67', 1),
(15, 'test2', '11', '11', 'scrypt:32768:8:1$JvEhFOfGKXFsubtK$93b751d380a48644fc95b961066fcc8acb0506d9efe94cbeca7b4f23449288e383b44240a2ce0a063a2060cdb28be524826a6e6f85a37346c11e6293240e1ee9', 3);

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `dostawcy`
--
ALTER TABLE `dostawcy`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nazwa` (`nazwa`);

--
-- Indeksy dla tabeli `profil`
--
ALTER TABLE `profil`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_tasmy` (`id_tasmy`),
  ADD KEY `id_pracownika` (`id_pracownika`);

--
-- Indeksy dla tabeli `szablon`
--
ALTER TABLE `szablon`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nazwa` (`nazwa`);

--
-- Indeksy dla tabeli `tasma`
--
ALTER TABLE `tasma`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_tasma_pracownik` (`pracownik_id`),
  ADD KEY `fk_tasma_dostawca` (`dostawca_id`),
  ADD KEY `fk_tasma_szablon` (`szablon_id`);

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
-- AUTO_INCREMENT for table `dostawcy`
--
ALTER TABLE `dostawcy`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `profil`
--
ALTER TABLE `profil`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `szablon`
--
ALTER TABLE `szablon`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `tasma`
--
ALTER TABLE `tasma`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `uprawnienia`
--
ALTER TABLE `uprawnienia`
  MODIFY `id_uprawnienia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

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
  ADD CONSTRAINT `fk_tasma_dostawca` FOREIGN KEY (`dostawca_id`) REFERENCES `dostawcy` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tasma_pracownik` FOREIGN KEY (`pracownik_id`) REFERENCES `uzytkownicy` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tasma_szablon` FOREIGN KEY (`szablon_id`) REFERENCES `szablon` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  ADD CONSTRAINT `fk_uzytkownicy_uprawnienia` FOREIGN KEY (`id_uprawnienia`) REFERENCES `uprawnienia` (`id_uprawnienia`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
