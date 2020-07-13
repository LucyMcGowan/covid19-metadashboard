
function(input, output, session) {
  ratings <- read_sheet(as_sheets_id(ratings_sheet))
  d <- read_sheet(as_sheets_id("https://docs.google.com/spreadsheets/d/1Xl0lCC8nwzjUPHTqfLlgTfXK8yA8DjJpQFFVOcSeN4M/"),
    col_names = c(
      "time", "title", "location", "link", "world",
      "country", "state", "county", "city", "playable",
      "notable"
    ),
    skip = 1
  )
  d <- d %>%
    mutate(
      world = ifelse(world == "Yes", as.character(icon("check")), as.character(icon("remove"))),
      country = ifelse(country == "Yes", as.character(icon("check")), as.character(icon("remove"))),
      state = ifelse(state == "Yes", as.character(icon("check")), as.character(icon("remove"))),
      county = ifelse(county == "Yes", as.character(icon("check")), as.character(icon("remove"))),
      city = ifelse(city == "Yes", as.character(icon("check")), as.character(icon("remove"))),
      playable = ifelse(playable == "Yes", as.character(icon("check")), as.character(icon("remove")))
    ) %>%
    distinct(link, .keep_all = TRUE)


  d <- left_join(d, ratings, by = "link") %>%
    arrange(-rating) %>%
    mutate(id = 1:nrow(d))


  ## thank you RStudio Community https://community.rstudio.com/t/add-a-button-into-a-row-in-a-datatable/18651/2
  buttonInput <- function(FUN, len, id, ...) {
    inputs <- character(len)
    for (i in seq_len(len)) {
      inputs[i] <- as.character(FUN(paste0(id, i), ...))
    }
    inputs
  }

  output$url_out <- renderUI({
    tags$a(
      href = glue("{vals$link}"),
      "View Dashboard in a new window",
      target = "_blank"
    )
  })

  vals <- reactiveValues(
    link = "https://coronavirus.jhu.edu/map.html",
    ratings = ratings
  )

  vals$data <- bind_cols(
    upvote = buttonInput(
      FUN = actionLink,
      len = nrow(d),
      id = "upvote_",
      label = "",
      icon("arrow-up"),
      onclick = 'Shiny.onInputChange(\"upClick\",  this.id);
      Shiny.onInputChange(\"downClick\", \"test\");'
    ),
    downvote = buttonInput(
      FUN = actionLink,
      len = nrow(d),
      id = "downvote_",
      label = "",
      icon("arrow-down"),
      onclick = 'Shiny.onInputChange(\"downClick\",  this.id);
      Shiny.onInputChange(\"upClick\", \"test\");'
    ),
    d,
    view = buttonInput(
      FUN = actionButton,
      len = nrow(d),
      id = "button_",
      label = "View",
      onclick = 'Shiny.onInputChange(\"lastClick\",  this.id)'
    )
  )


  output$df <- DT::renderDataTable({
    df <- vals$data %>%
      select(
        view, rating, upvote, downvote, title, location, world,
        country, state, county, city, playable, notable
      )
    datatable(df,
      escape = FALSE, rownames = FALSE, colnames =
        c(
          "", "Rating", "", "", "Description", "Country", "World Data",
          "Country Data", "State Data", "County Data", "City Data", "Playable Charts",
          "Novel Feature"
        ),
      options = list(ordering = FALSE, scrollX = TRUE)
    )
  })

  observeEvent(input$upClick, {
    if (input$upClick != "test") {
      t <- vals$data %>%
        filter(id == as.numeric(strsplit(input$upClick, "_")[[1]][2])) %>%
        pull(link)
      if (t %in% vals$ratings$link) {
        vals$ratings <- vals$ratings %>%
          mutate(rating = case_when(
            link == t ~ rating + 1,
            TRUE ~ rating
          ))
        vals$data <- vals$data %>%
          mutate(rating = case_when(
            link == t ~ rating + 1,
            TRUE ~ rating
          ))
      } else {
        vals$ratings <- vals$ratings %>%
          bind_rows(tibble(
            link = t,
            rating = 1
          ))
        vals$data <- vals$data %>%
          mutate(rating = case_when(
            link == t ~ 1,
            TRUE ~ rating
          ))
      }
      write_csv(vals$ratings, "temp.csv")
      drive_update(
        as_sheets_id(ratings_sheet),
        "temp.csv"
      )
    }
  })


  observeEvent(input$check, {
    output$check_link <- renderUI({
      if (input$url %in% vals$data$link) {
        "We already have this Dashboard in our database."
      } else {
        "It doesn't look like we have this one yet."
      }
    })
  })
  observeEvent(input$downClick, {
    if (input$downClick != "test") {
      t <- vals$data %>%
        filter(id == as.numeric(strsplit(input$downClick, "_")[[1]][2])) %>%
        pull(link)
      if (t %in% vals$ratings$link) {
        vals$ratings <- vals$ratings %>%
          mutate(rating = case_when(
            link == t & rating > 0 ~ rating - 1,
            link == t & rating == 0 ~ 0,
            TRUE ~ rating
          ))
        vals$data <- vals$data %>%
          mutate(rating = case_when(
            link == t & rating > 0 ~ rating - 1,
            link == t & rating == 0 ~ 0,
            TRUE ~ rating
          ))
      } else {
        vals$ratings <- vals$ratings %>%
          bind_rows(tibble(
            link = t,
            rating = 0
          ))
        vals$data <- vals$data %>%
          mutate(rating = case_when(
            link == t ~ 0,
            TRUE ~ rating
          ))
      }
      write_csv(vals$ratings, "temp.csv")
      drive_update(as_sheets_id(ratings_sheet), "temp.csv")
    }
  })

  observeEvent(input$lastClick, {
    updateTabItems(session, "tabs", "dash")
    vals$link <- vals$data %>%
      filter(id == as.numeric(strsplit(input$lastClick, "_")[[1]][2])) %>%
      pull(link)
  })

  output$dashboard_list <- renderUI({
    d <- vals$data %>%
      mutate(rate = ifelse(is.na(rating), "0", rating))
    global <- d %>%
      filter(world == "<i class=\"fa fa-check\"></i>") %>%
      arrange(title)
    us_country <- d %>%
      filter(location == "United States" & country == "<i class=\"fa fa-check\"></i>") %>%
      arrange(title)
    us_state <- d %>%
      filter(location == "United States" & state == "<i class=\"fa fa-check\"></i>") %>%
      arrange(title)
    us_county <- d %>%
      filter(location == "United States" & county == "<i class=\"fa fa-check\"></i>") %>%
      arrange(title)
    not_us <- d %>%
      filter(location != "United States" & world != "<i class=\"fa fa-check\"></i>") %>%
      arrange(title)
    tagList(
      h2("Global"),
      p(HTML(glue_collapse(glue("<a href = '{global$link}' target = '_blank'> {global$title} </a> votes: {global$rate}<br> <br>")))),
      h2("United States"),
      h3("National-level"),
      p(HTML(glue_collapse(glue("<a href = '{us_country$link}' target = '_blank'> {us_country$title} </a> votes: {us_country$rate}<br> <br>")))),
      h3("State-level"),
      p(HTML(glue_collapse(glue("<a href = '{us_state$link}' target = '_blank'> {us_state$title} </a> votes: {us_state$rate}<br> <br>")))),
      h3("County-level"),
      p(HTML(glue_collapse(glue("<a href = '{us_county$link}' target = '_blank'> {us_county$title} </a> votes: {us_county$rate}<br> <br>")))),
      h2("Outside the US"),
      p(HTML(glue_collapse(glue("<a href = '{not_us$link}' target = '_blank'> {not_us$title} </a> votes: {not_us$rate}<br> <br>")))),
    )
  })

  output$dash <- renderUI({
    out <- tags$iframe(src = vals$link, height = "1000", width = "100%")
    print(input$link)
    print(out)
    out
  })
}
