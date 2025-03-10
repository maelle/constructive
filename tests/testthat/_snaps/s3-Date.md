# Date

    Code
      construct(as.Date(.leap.seconds[1:5]))
    Output
      as.Date(c("1972-07-01", "1973-01-01", "1974-01-01", "1975-01-01", "1976-01-01"))
    Code
      construct(as.Date(.leap.seconds[1:5]), opts_Date("as_date"))
    Output
      lubridate::as_date(c("1972-07-01", "1973-01-01", "1974-01-01", "1975-01-01", "1976-01-01"))
    Code
      construct(as.Date(.leap.seconds[1:5]), opts_Date("date"))
    Output
      lubridate::date(c("1972-07-01", "1973-01-01", "1974-01-01", "1975-01-01", "1976-01-01"))
    Code
      construct(as.Date(.leap.seconds[1:5]), opts_Date("new_date"))
    Output
      vctrs::new_date(c(912, 1096, 1461, 1826, 2191))
    Code
      construct(as.Date(.leap.seconds[1:5]), opts_Date("as.Date.numeric"))
    Output
      as.Date(c(912, 1096, 1461, 1826, 2191), origin = "1970-01-01")
    Code
      construct(as.Date(.leap.seconds[1:5]), opts_Date("as_date.numeric"))
    Output
      lubridate::as_date(c(912, 1096, 1461, 1826, 2191))
    Code
      construct(as.Date(.leap.seconds[1:5]), opts_Date("as.Date.numeric", origin = "2000-01-01"))
    Output
      as.Date(c(-10045, -9861, -9496, -9131, -8766), origin = "2000-01-01")
    Code
      construct(as.Date(.leap.seconds[1:5]), opts_Date("as_date.numeric", origin = "2000-01-01"))
    Message
      {constructive} couldn't create code that reproduces perfectly the input
      i Call `construct_issues()` to inspect the last issues
    Output
      lubridate::as_date(c(-10045, -9861, -9496, -9131, -8766))
    Code
      construct(as.Date(.leap.seconds[1:10]))
    Output
      as.Date(c(
        "1972-07-01", "1973-01-01", "1974-01-01", "1975-01-01", "1976-01-01",
        "1977-01-01", "1978-01-01", "1979-01-01", "1980-01-01", "1981-07-01"
      ))
    Code
      dates <- as.Date(.leap.seconds[1:5])
      dates[1] <- Inf
      dates[2] <- -Inf
      construct(dates)
    Output
      as.Date(c(Inf, -Inf, 1461, 1826, 2191), origin = "1970-01-01")
    Code
      construct(dates, opts_Date("as_date"))
    Output
      lubridate::as_date(c(Inf, -Inf, 1461, 1826, 2191))
    Code
      construct(dates, opts_Date("date"))
    Output
      lubridate::as_date(c(Inf, -Inf, 1461, 1826, 2191))
    Code
      construct(dates, opts_Date("new_date"))
    Output
      vctrs::new_date(c(Inf, -Inf, 1461, 1826, 2191))
    Code
      construct(dates, opts_Date(origin = "2000-01-01"))
    Output
      as.Date(c(Inf, -Inf, -9496, -9131, -8766), origin = "2000-01-01")
    Code
      construct(dates, opts_Date("as_date", origin = "2000-01-01"))
    Output
      lubridate::as_date(c(Inf, -Inf, -9496, -9131, -8766), origin = "2000-01-01")
    Code
      construct(dates, opts_Date("date", origin = "2000-01-01"))
    Output
      lubridate::as_date(c(Inf, -Inf, -9496, -9131, -8766), origin = "2000-01-01")

