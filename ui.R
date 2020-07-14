dashboardPage(
  title = "COVID-19 Meta Dashboard",
  dashboardHeader(
    title = "COVID-19 Meta Dashboard",
    titleWidth = 320,
    disable = FALSE
  ),
  dashboardSidebar(
    width = 320,
    sidebarMenu(
      id = "tabs",
      menuItem(
        "Home",
        tabName = "home"
      ),
      menuItem(
        "Search dashboards",
        tabName = "search",
        icon = icon("search")
      ),
      menuItem(
        "Add to the database",
        tabName = "data",
        icon = icon("database")
      ),
      menuItem(
        "View selected dashboard",
        tabName = "dash",
        icon = icon("tachometer-alt")
      ),
      menuItem(
        "About",
        tabName = "about",
        icon = icon("question")
      )
    )
  ),
  dashboardBody(
    useShinyjs(),
    includeCSS("www/custom.css"),
    tags$script(HTML("$('body').addClass('fixed');")),
    tabItems(
      tabItem(
        tabName = "home",
        fluidRow(
          box(
            width = 12, status = "primary",
            h1("COVID-19 Meta Dashboard"),
            p(glue(
              "This dashboard was designed to collect COVID-19 dashboards in ",
              "a single location. Below is a listing of all dashboards included. ",
              "Navigate in the side bar to the 'Search dashboards' tab to search all dashboards ",
              "by keyword as well as up/downvote dashboards. Navigate to the ",
              "'Add to the database' tab to add missing dashboards."
            )),
            uiOutput("dashboard_list")
          )
        )
      ),
      tabItem(
        tabName = "search",
        DT::dataTableOutput("df")
      ),
      tabItem(
        tabName = "data",
        includeMarkdown("data.md"),
        textInput("url", "Check the URL of the dasboard"),
        actionButton("check", "Check"),
        uiOutput("check_link"),
        tags$iframe(
          id = "googleform",
          src = "https://docs.google.com/forms/d/e/1FAIpQLSdcq-I98VZeA7NjUxBvqMGmdg5ahRucDVwxo057E-x9BmeM-Q/viewform?embedded=true",
          width = "100%",
          height = 2158,
          frameborder = 0,
          marginheight = 0
        )
      ),
      tabItem(
        tabName = "dash",
        fluidRow(
          style = "height:100vh",
          uiOutput("url_out"),
          uiOutput("dash")
        )
      ),
      tabItem(
        tabName = "about",
        includeMarkdown("about.md"),
        uiOutput("thanks")
      )
    )
  )
)
