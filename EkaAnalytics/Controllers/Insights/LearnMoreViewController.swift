//
//  LearnMoreViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 05/02/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class LearnMoreViewController: GAITrackedViewController {
    
    
    //Check this link for library details
    //https://github.com/evermeer/AttributedTextView
    
    @IBOutlet weak var attributedTextView:AttributedTextView!
    
    var app:App!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.learnMore
        
        let inventoryAnalytics =  ("View and track projected inventory.\n\n".black.size(17)
            
            + """
              \nRole
                -Trader, Logistics Manager\n\n
              """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            + """
              \nSegment
                - Agriculture: Grains
                - Softs: Coffee, Sugar
                - Dairy
                - Energy: Gas, Crude and
                   Refined Oil,Biofuel,Coal
                - Metals\n\n
              """.backgroundColor(Utility.cellBorderColor).size(17))
            
            .append("\nThe Inventory Analytics App allows traders and logistic managers to view projected and forward-looking inventory on a daily basis taking in account long and short positions. It also helps analyze inventory COG VS market to make better buy and sell decisions.\n\n\n".black.size(17)
                
                + "Technical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                + """
              1. Data Sources
                 - Physical trades
                 - Nominations
                 - Actual delivery
                 - Market prices from TR
                 - Blend Details

              2. Frequency
                 - On Demand

              3. Pre-Built Model
                 - Projected inventory

              4. Complexity
                 - High

              5. Enrichments
                 - 10
              """.black.size(17)
            ).append(
                
                "\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                    
                    +   """
            1. Computes daily opening and closing balance for inventory by product, grade and location matching up sales and purchases\n
            2. Track planned vs actual delivery\n
            3. Predictive analysis allows users to see likley trend based on past pattern\n
            4. Computes cost of goods of inventory and tracks against market price\n
            5. Analyze historical supply demand patterns\n
            6. Alerts and monitors to signal breaches on inventory position, high volume trade, -ve inventory, market and inventory price breaches
            """.black.size(17)
            ).append("\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
                1. View opening, closing balance, net long, short by location\n
                2. Analyze inventory price against market to take strategic decision on whether to buy and store more or to sell\n
                3. View most profitable inventory locations and grades\n
                4. Track planned Vs actual delivery by date\n
                5. View estimated deliveries based on past projections\n
                """.black.size(17)
        )
        
        //=======================================++==================+=========++++=========++++++==============
        
        let procurementAnalysis = ("Track commodity risk, coverage, spend and variance across all categories and make better buying decisions while managing price and volume risk.\n\n".black.size(17)
            
            + """
          \nRole
            - Buyer, Category Manager, Procurement Finance, CFO, Risk Manager\n\n
          """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            + """
          \nSegment
             - F&B, Industrial Manufacturing, PetChem\n\n
          """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\nThe Procurement Analysis App allows manufacturing companies track, monitor, analyze and manage enterprise-wide budgeted, actual and projected spends. It lets users simulate projected spend and perform detailed spend attribution analysis.\n\n With this app, manufacturing companies can also view coverage and price risk to perform market simulations and see resulting impact on coverage. The app sends user alerts in the event of coverage breaching corporate governance policies.".black.size(17)
            
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Annual budgets and Volume forecasts
                - Physical Coverage by cost component
                - Derivative trades
                - Forward Prices from TR
                - FX rates from TR
                - Cost Models
                - Actuals from invoices
            
            2. Frequency
                - On Demand
            
            3. Pre-Built Model
                - Procurement
            
            4. Complexity
                - High
            
            5. Enrichments
                - 40
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Integrate data from multiple systems – Bring together large volumes of disparate information from systems such as ERP and spreadsheets to run analyses and gain answers immediately, instead of waiting a week or longer

            2. Simulate market changes, coverage, and spend – Run complex forecasting models and scenarios, ask "what if" questions to determine expected results. Evaluate how projected changes in market prices, supplier costs, and demand can affect the bottom line

            3. Track exposures — View forward-looking coverage by component and against changing market prices. Gain consolidated views of coverage by component or supplier. Learn individual cost contributors by component. Enable automatic corrections of coverage to components. View coverage movement over a period of time

            4. View historical spend – Understand supplier behavior and pricing trends. Gain improved analysis of spend behavior

            5. Set up monitors – Get alerts when certain spend and coverage thresholds are reached. Determine which components are most likely to exceed budget

            6. Track Hedges – Analyze hedging strategies, track market buy signals and automatic and manual allocation of hedges to individual items to track coverage at most granular level

            7. Customize – Create additional insights with flexible and multiple hierarchy

            8. Simple and interactive UI to drill down to individual transactions
            """.black.size(17)
            ).append("\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Enable executive decision making with customized reporting that aids collaboration across the organization

            2. Make the most profitable decisions by performing analysis on forecasted, actual, and projected spend. Include gains and losses of hedge programs in spend analysis

            3. Predict the impact to coverage with market simulations that illustrate the effect on coverage before taking action

            4. Make course corrections by pinpointing contributing factors with attribution analysis.

            5. Maintain coverage within corporate governance policies

            6. Coverage analysis and reports to track over and under coverage along with coverage movement

            7. Analyze hedge strategies and its effect on overall spend
            """.black.size(17)
        )
        
        //====================================================================================================
        
        let purchaseAnalysis = ("Compute Raw Material Margin per Smelter with a possiblity of simulation to achieve highest margins. Take the right decision on purchasing the right ores, and feed the ores to the right smelters\n".black.size(17)
            +   """
            \nRole
                - Purchasing Officer, Smelter Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +  """
            \nSegment
                - Metals\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
        
        ).append(
        "\nThe Purchase Analysis App enables users to make the right decision on purchasing the right ores and on feeding the ores to the right smelters. It also allows users to:\n 1.Quickly look at Qualities that return the highest RMM. \n 2.Perform analysis across Qualities on various parameters such as Free Metal revenue, Treatment Charges, Penalty Charges, etc.\n 3.Drilldown into the components that make up the RMM and analyze the contribution of each component to the RMM.".black.size(17)
        ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
        
        +   """
        1. Data Sources
            - Contract
            - Quality (Assay information)
            - Processor data (Smelter & Feeding Point properties)
            - Other Costs (Landfill Cost, etc)
            - Market Prices for traded elements across different purchasing options/time horizons like spot, budget and long-term
            - FX rates
        """.black.size(17)
        
        ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
        
        +   """
        1. Calculate Raw Material Margin (RMM) in real-time for a combination of Quality, Feeding Point and Supplier. The algorithm provides result of RMM for selected qualities on latest contracts from different suppliers if the ore is processed in different feeding points of smelters.
        
        2. Ability to create portfolios for a combination of the following dimensions and use them in insight creation. Dimension - Quality,Supplier and Feeding Point
        """.black.size(17)
        ).append("\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
        
        +   """
        1. Ability to visualize RMM by quality (sorted by highest RMM) across different levels like Supplier, Feeding Point, RRM Movement through its components.
        
        2. Ability to view and drill down to different components of Raw Material Margin like: Free Metal Value, Treatment Charges, Refining Charges, Penalty, Landfill Cost, Payment Terms in Base Currency for a combination of Quality, Feeding Point and Supplier
        """.black.size(17)
            ).append("\n\n\nMonitor\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
        1. Shows the monitors applicable for the Insight and the Monitor Summary page; the summary page shows the monitor, the view by parameters box, and the trade details for the monitor.
        
        2. Ability to filter the RMM details grid by clicking on the view by grid.
        """.black.size(17)
            ).append("\n\n\nSimulation\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
        1. Ability to create a scenario by shocking Quality assay values by metals, Contract info (Payable and Deductions) by suppliers, Charges (TC/RC/Penalty) by suppliers, Market prices of metal prices across different time horizons, or FX rates across different time horizons to create a simulation.
        
        2. Ability to add a new quality through collections into an existing data-set, include the same in a scenario and run simulation.
        """.black.size(17)
        )
        //====================================================================================================
        
        let riskAndMonitoring = ("Define risk limit policies, analyze global risk across multiple portfolios and books, and track limit breaches and utilizations.\n".black.size(17)
            +   """
            \nRole
                - Risk Team and Traders\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +  """
            \nSegment
                - Agriculture: Grains
                - Softs: Coffee, Sugar
                - Dairy
                - Energy: Gas, Crude and Refined Oil, Biofuel\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            ).append(
                "\nThe Risk and Monitoring App lets you define risk limit policies against position, P&L, and VaR, with alert notifications for user groups in the event of a breach. It lets you analyze details into the breach to assess individual impact of trades on the P&L.\nAdditional views from the trading results data can be set up monitor to monitor the breach details in more depth such as tracking the worst performing trades by P&L.".black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Physical and financial trades from CTRM or spreadsheets
                - Futures, cash and basis prices from TR
                - Commodity forward prices from TR
                - Historic commodity, FX price and interest rate data from TR
                - Position
                - P&L
                - VaR
                - P&L explained
            
            2. Frequency
                - End of day and/or near real time
            
            3. Pre-Built Model
                - Risk limit monitors against position, p&L and VaR
            
            4. Complexity
                - Medium
            
            5. Enrichments
                - 5
            """.black.size(17)
                
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Consolidates position and P&L from CTRM and multiple spreadsheets to set limits against.

            2. Conversion of units and currencies to base unit for limit reporting.

            3. Calculates limit results based on the limit policy configurations on positions, P&L.

            4. Calculates VaR results using different VAR methods and scenarios.

            5. Flexibility to support regional as well as a global view

            6. Alerts and monitors to signal breaches on position, prices, p&l, VaR and any external data

            7. Track limit policies over time.
            """.black.size(17)
            ).append("\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. View summary of breaches by positions, P&L and VaR limits on a daily basis.

            2. Track the limit utilization across the different policy dimensions.

            3. Track worst trades by p&l performance.

            4. Set limits policies to alert traders and risk team in the event of a breach.
            """.black.size(17)
        )
        //====================================================================================================
        
        let VaR = ("Identify risk by comparing potential market scenarios derived from multiple simulation models. Sophisticated algorithms built-into the system lets you view volatility and correlations within portfolios to assess the impact of market risks.".black.size(17)
            
            + "\n\n".backgroundColor(.white)
            
            +   """
            \nRole
                - Trader, Finance, Risk Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture: Grains
                - Softs: Coffee, Sugar
                - Dairy
                - Energy: Gas, Crude and Refined Oil, Biofuel
                - Base and Precious\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            ).append(
                
                """
        \nThe VaR App consolidates information from different sources, including C/ETRM spreadsheets and market data providers. It provides insights into market risk using VaR results, thus enabling users to make more informed decisions and take mitigation measures, if required.
        This app calculates VaR using Monte Carlo, Historical Simulation and Parametric methods. It supports the creation of flexible VaR risk portfolios and multiple market scenarios to predict potential impact of price shocks and 'what-if' trades.
         
         With this app, users can automate the VaR process to run at set times or intraday (on demand) as needed. It lets users customize VaR dashboards to be viewed as per user roles, and also configure VaR limits, with a round the clock monitoring system that sends alerts in the event of a breach.
        """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Physical trades
                - Derivative trades
                - FX Trades
                - Forward Prices from TR
                - FX rates from TR
                - Interest rate from TR
                - Historical data from TR
            
            2. Frequency
                - End of day /Periodic /On demand
            
            3. Pre-Built Model
                - FEA MakeVC and VaR method models
            
            4. Complexity
                - Complex
            
            5. Enrichments
                - 10
            """.black.size(17)
                
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Manage different trade types – VaR app allowes users to upload different trade types such as commodity physical trades, futures, options, forwards etc. and calculate VaR for each trade type

            2. Integrate data easily from multiple systems – Bring together data from disparate sources such as market prices from data providers like Thomson Reuters, Bloomberg, trade information from CTRM/ETRM systems or from csv/excel sheets maintained by users

            3. Calculate VaR for Portfolios at different levels – Users can configure different portfolios and sub-portfolios and can run VaR on them together or separately

            4. Multiple VaR Models – Use different models such as Parametric (also called Analytical or variance-covariance), Monte Carlo Simulation and Historical Simulation models. Users can run different models on the same portfolio and compare the results

            5. Get Volatility & Correlation information – Get information on volatility and corrleation between different market curves, interest rates and exchange rates

            6. Run VaR on Stressed Prices – Shock prices on selected curves and run VaR. User can compare VaR values run on normal and shocked prices to see impact of what-if changes in market

            7. Setup Risk Limits on VaR - User can setup risk limits on VaR values so that they will know when VaR has breached governance/compliance limits

            8. Visualization – Users have powerful visualization options available which they can use to view VaR values. Users can configure to view VaR histogram, historical trendlines as well as pure tabular view of VaR values using diffferent methods
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Single portfolio with multiple scenarios - View and compare VaR Scenarios at 90, 95, 99% CI across a 1 day holding period results for the Monte Carlo, Historical Simulation and Parametric methods for the global risk portfolio

            2. View and analyze single or multiple scenarios across multiple portfolios

            3. View underlying parameters, trades , prices that is contributing to the VaR run

            4. Compare historical VaR run overtime and view trends

            5. Monitor the hard and soft risk limits set on the VaR results to check on hard and soft risk breaches and see utilization.

            6. Create What If and price shocks and run VaR against the risk portfolios to view the impacts and make comparisons.
            """.black.size(17)
                
        )
        
        //====================================================================================================
        
        let tradeFinance = ("Get recommendations on best banks to engage with for Loans and LC instruments. Monitor trade finance risks based on credit rating, value, shipment dates and more.\n\n".black.size(17)
            
            +   """
            \nRole
                - Analyst, CFO, Finance Manager, Trader, Risk Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture, Biofuels, Food and Beverage, Industrial Manufacturing, Metals, Oils, Gas, Power\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            ).append("\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Bank Cost Quotation
                - Trade Finance Scenario
            
            2. Frequency
                - On Demand
            
            3. Complexity
                - Medium
            
            4. Enrichments
                - 8
            """.black.size(17)
                
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Recommendation of the best bank to engage for Trade Finance instruments

            2. Get best and least charging Issuing, Advising, Financing and Negotiating Bank

            3. Financial Instrument Cost calculations for Interest, Import/ Export, Document, Advising, Confirming, Deferred Payment and Negotiating Charges
            """.black.size(17)
            ).append("\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Trade Finance Recommendations – considering all Costs, Risks and Value

            2. Loan comparison across various tenors and Banks by cost

            3. Risk Tracking of LC against Bank Rating, Contract Shipment, etc.
            """.black.size(17)
        )
        
        //====================================================================================================
        
        
        let pAndlExplained = ("Explain P&L and position movements with 99% accuracy by tracking over 150 events in a fraction of the time it took earlier.\n\n".black.size(17)
            +   """
            \nRole
                - Trader, Finance, Risk Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture: Grains
                - Softs: Coffee, Sugar
                - Dairy
                - Energy: Gas, Crude and Refined Oil, Biofuel
                - Metals\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   "\n\nThe P&L Explained app helps identify root causes in P&L, enabling users to make better decisions faster. Finance, audit, risk, and traders can gain a clear understanding of P&L movement by drilling down to individual transaction level. Managers can quickly spot inaccurate assumptions that could affect future trading decisions and measure the performance of traders, books, and business units.".black.size(17)
            
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Physical trades
                - Trade Cancellations
                - Derivative trades
                - Forward Prices from TR
                - FX rates from TR
                - Basis from TR
                - Location differentials
                - Inventory details
                - Accruals and cost estimate details
                - Realized and unrealized p&l between any 2 dates
            
            2. Frequency
                - End of day / Periodic
            
            3. Pre-Built Model
                - P&L Attribution
            
            4. Complexity
                - High
            
            5. Enrichments
                - 10
            """.black.size(17)
                
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Over 50+ configurable buckets to explain P&L change most granularly and with less than 5% in unexplained

            2. Complex calculations to compute changes from open to execution to realization

            3. Make timely decisions around position sizes and direction based on day to day trends

            4. Gain insight into market movement split between exchange price & FX

            5. Understand P&L movement for contract amendments (price, estimates, grade, etc.) and non-trader actions like overfill/underfill/washouts

            6. Recalculate P&L for realized buckets to explain the change from open to executed buckets

            7. View and analyze position and root-cause changes at any entity level including book, trader, origin, geography, type, etc

            8. Simple and interactive UI to drill down to individual transactions
            """.black.size(17)
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. View P&L explained buckets with drill down to trade level

            2. View P&L change by any pre-defined or user-defined entity like strategy, BU, region, trader

            3. Monitor to identify maximum p&l and position swing by strategy, book, commodity, grade and other dimensions

            4. Analyze historical data to spot outliers
            """.black.size(17)
        )
        
        
        let positionAndMarkToMarket = ("Spot opportunities and risks on time with real-time visibility into overall exposure, aligned with potential impact of dynamic market prices.\n\n".black.size(17)
            
            +   """
                \nRole
                    - Trader\n\n
                """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
                \nSegment
                    - Agriculture: Grains
                    - Softs: Coffee, Sugar, Dairy
                    - Energy: Gas, Crude and Refined Oil, Biofuel
                    - Metals\n\n
                """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\nThe Position and Mark to Market App automates a four-day manual reconciliation process into a 30 second task, providing a single point of truth on exposure. It provides real time visibility into your inventory, position and exposure. It lets you take advantage of opportunities and mitigate risks with predictive algorithms to make more informed and strategic hedging decisions.".black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Physical trades
                - Derivative trades
                - Forward Prices from TR
                - Historical prices from TR
            
            2. Frequency
                - End of day and/or near real time
            
            3. Pre-Built Model
                - Position Consolidation

            4. Complexity
                - Medium

            5. Enrichments
                - 10
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +     """
             1. Consolidates position from CTRM, broker system, and multiple spreadsheets

             2. Conversion of units and currencies to base unit for reporting

             3. Support for cross hedging, hedge ratios

             4. Flexibility to handle all pricing types like fixed, basis fixed, index, Futures fixed, unpriced and report them under different pre-defined or user defined buckets

             5. Flexibility to view exposure in terms of original product, feedstock or output product

             6. Flexibility to take in outright or delta adjusted positions for options

             7. View historical and forward price trends

             8. User defined rules for hedging strategy

             9. Add additional user defined fields to customize reports

             10. Flexibility to support regional as well as a global view

             11. Alerts and monitors to signal breaches on position and prices

             12. Track changes and movement over a period of time
            """.black.size(17)
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Overall Position Analysis to view position by trade type, price type and change between yesterday and today

            2. Hedge analysis to Comparison between recommended hedge and actual hedge strategy

            3. Supply demand analysis to view long and short positions by delivery months and view market price and market price trend to decide to buy now and store vs buy later

            4. Monitor to identify maximum position swing by strategy, book, commodity

            5. View PTBF analysis to see market trend and upcoming contracts for price fixing. View historical price fixes by date to analyze effectiveness and improve subsequent decision making

            6. View position movement over a period of time to view trends

            7. View position limits and underlying trades breaching the limits

            8. View outliers and position movement trends
            """.black.size(17)
                
        )
        
        //====================================================================================================
        
        let regulatoryAndCompliance = ("An intelligent, flexible and robust solution designed to meet necessary regulatory obligations in a dynamic regulatory environment.\n\n".black.size(17)
            +   """
            \nRole
                - Risk Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture: Grains, Canola
                - Energy: Physical Power, Gas, Renewables
                - Derivatives: FX, Contract For Differences, Credit, Interest Rates\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nThe Regulatory and Compliance App provides a wide range of regulatory reports like EMIR, CFTC, MiFiD, ICE, MAR meeting different obligations, based on regulators, geography, commodity or asset class.
            The solution is integrated with Trade Repository, allowing users to submit transactions and track its status while meeting reporting deadlines. The highly scalable solution can be easily adapted with dynamic regulatory requirements.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Transaction Data
                - Depending upon the Regulatory Report
            
            2. Market Prices from TR
                - if applicable
            
            3. LEI {Legal Entity Identifier} Code from TR
                - if applicable
            
            2. Frequency
                - Adhoc/On Demand/Scheduled as per Regulatory Requirement
            
            3. Complexity
                - Medium
            
            4. Enrichments
                - Regulatory Reports are highly customized as the fields to be reported are based on the reporting requirements
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Handle Multi-Geographic and Cross Commodity

            2. Visualization – User can utilize the reported data in various visuals, dashboards from Tracking or Surveliance perspective.

            3. Monitoring – Alerts and Notifications can be set up for users to manage deadlines, act upon rejection by trade repository

            4. Exhaustive Reporting

            5. Error Handling capabilities

            6. Deal Life Cycle Handling – Handling Deal Life Cycle Events by itself as per Trade Repository Integeration.

            7. UTI Generation – Can generate UTI for each transaction with either Concatenation or Algorithmic based. For e.g ISDA UTI for EMIR or UTI for REMIT

            8. Comprehensive Entity Mapping
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Overall Summary on Single or Multiple Geography

            2. Status Summary with Drill Down to Report Level

            3. Individual Report on Consolidated Level
            """.black.size(17)
        )
        
        //====================================================================================================
        
        let planPerformance = ("Facilities such as grain sites, port terminals, and mines are under constant pressure to increase throughput and to add value to stored or mined products. These facilities then use processes such as blending, milling, separating, crushing, or treating of products for optimal fulfillment of orders. Bulk handling facilities must continually work to both increase throughput and achieve exacting cargo requirements. Receival, transfer, and loading functions must become more efficient.\n\n".black.size(17)
            ).append("\nUsing the Plan Performance App, the user can:\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
                    1. Automate process decisions

                    2. Maximize throughput

                    3. Make better stacking and reclaiming decisions

                    4. Improve operational awareness and control with real-time product tracking and smart sequence control\n
            """.black.size(17)
            ).append( "\nKey measures for evaluating performance of a plan for each resource are:\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
                    1. Variance between actual tonnes from the Insight CM based on the operator's tasks, the logistics plan and the production coordinator's plan in CAC.

                    2. Variance of cumulative tonnes and cumulative deviation by a resource for a period of time, say last seven days.

                    3. Variance from the target rates compared with net loading rates and gross loading rates by resource and product.

                    4. Visibility of the Number of inbound trains and total outbound tonnage from the site, plotted against days of the week.

                    5. Visibility of the number of trains at planned and unplanned dumping stations, i.e. , the number of trains that were dumped or not dumped as planned, i.e., they were dumped at the station assigned to them in the production coordinator's plan.

                    6. Visibility of the number of ships at planned berths/unplanned berths, i.e., trains that were docked at the berth assigned to them in the production coordinator's plan.

                    7. Measures of tonnes that were reclaimed from planned/unplanned stockpiles. i.e., the no of tonnes reclaimed from stockpiles by resource that planned/not planned to be used as per the production coordinator's plan for a period of time.

                    8. Visibility on the number of trains in the dumping stations that are in/out of sequence based on the planned time in the production coordinator's plan.

                    9. Visibility of number of trains that arrive early, on-time or late based on their designated time in the production coordinator's plan.

                    10. Visibility on roll up by year, month, day, and shift of time spent and tonnes moved, adhering to deviating from the plan for a period of time.
            """.black.size(17)
        )
        
        //====================================================================================================
        
        let preTradeAnalysis = ("Arrive at the best Price and Margin for a Trade.\n\n".black.size(17)
            +   """
            \nRole
                - CRO, CFO, Trader, Risk Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture, Biofuels, Food and Beverage, Oil and Gas, Power, Industrial Manufacturing\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nIn order to generate the best possible Price and Margin, there is a need to be able to determine the possible costs and the best logistic route. The Costs involved are of various categories like Freight Costs based on the movement, Product Cost, Finance Costs, etc. In addition, there are different Units of Measurement used in each cost, coupled with different Currencies and/or weight Conversion factors
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1.  Data Sources
                Pre-Trade Scenario
                Logistics Path          - Inland Freight
                                        - Ocean Freight
                                        - List of Transloading Facilities
                                        - Stowage Cost
                                        - Transloading Cost
                                        - Packing Details
                                        - Shipment Capacity Details
                Product Cost Details    - Product Cost
                                        - Packing Costs
                                        - Processing Costs
                Inspection and Analysis - General Costs
                Customs
                Financial Costs         - Payment Rates
                                        - Finance Rate
                                        - Country Rate
                FX Rate

            2.    Frequency             - Online

            3.    Complexity            - High
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. To generate all possible options of fulfilling a Sale Offer with corresponding Costs and Sale Price. Based on, Cost of Products, Logistic Routes, Processing, Customs, Finance and General Costs

            2. To generate the best route based on User Defined INCO Term and Route mapping, for example Sale Offer for a FCA through “Pickup and Delivery” and “Transload”

            3. To calculate the Revised Offer Volume – this functionality helps utilize the complete capacity of an Equipment based on its Stowage, thereby reducing per MT cost of goods.

            4. To generate the most cost effective permutation and combinations of the 2 Leg logistic route through Transloader/ Container Yard with details of mode of transport and equipment to use.

            5. Ability to append/attach ANY User Defined Costs such as the Premium, Bagging, Bag, Palletization, Processing, etc.
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Top Margin and Price

            2. Best Prices and Costs

            3. Most Traded Scenarios
            """.black.size(17)
        )
        
        //====================================================================================================
        
        let farmerConnect = ("Increase Farmer loyalty and stickiness by enabling Farmer to make better contracts with price transparency and alerts coming from multiple sources and channels. Enable real time updates on tickets, deliveries and validate accounting entries.\n\n".black.size(17)
            +   """
            \nRole
                - Trader, Grower Services\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture, Biofuels, Food and Beverage\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nFarmer Connect enables BOTH the business and its farmers to be on top of every business activity by giving most refined and relevant business insights and with an always on alerts/notifications feature set.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1.  Data Sources
                    - Bid/Price Sheet
                    - Contract and Trading system
                    - Ticket and Delivery application
                    - Accounting system
                    - Advices/ Market Data

            2.    Frequency
                    - Online

            3.    Complexity
                    - Low
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Retrieves, filters and based on the Farmer preference, generates Insights and Alerts for Offers, Existing Contracts and their Status, Tickets/Transportation Details, and Sales and Invoice/Payments data with the Company.
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Bid Information

            2. Contracts Insight

            3. Tickets and Deliveries

            4. Sales and Invoices

            5. Payments

            6. Agronomy Advice
            """.black.size(17)
        )
        
        //====================================================================================================
        
        
        let diseasePrediction = ("Historical Rust Incidence and Rust Severity with weather parameters\nThe model uses advance analytics agriculture feature engineering, which is modelled to factor in weather that impacts the plant, such as sunshine period, relative humidity, cloud cover, and other weather parameters. This with historical analysis such as seasonality, variety, location and other factors are modelled to bring out the Disease Prediction\n\n".black.size(17)
            ).append("\n\nDataset\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1.  Weather Data Daily

            2.  Weather Data Hourly

            3.  Historical Disease Incidence Data
            """.black.size(17)
        )
        
        //====================================================================================================
        
        let optionsValuation = ("Options are non-linear instruments, whose value does not directly correlate with the value of underlying asset (commodity futures, equities, etc.) Hence it becomes imperative to understand the true value of an option and how it relates with underlying asset prices and other market parameters. The purpose of option valuation app is to allow users to find the true value of their option trades, along with key option Greek variables.\n\n".black.size(17)
            +   """
            \nRole
                - Trader, Finance, Risk Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture: Grains
                - Softs: Coffee, Sugar, Dairy
                - Energy: Gas, Crude and Refined Oil, Biofuel
                - Metals\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nThe option valuation App consolidates options information from different sources, including C/ETRM systems, brokers and market data providers (for market prices).
            This app performs Option valuation using Black Scholes method. It supports the creation of flexible options portfolios to perform valuation of multiple trades.
            With this app, users can automate the run valuation process at set times or intraday (on demand) as needed. It lets users customize Option Valuation dashboards to be viewed as per user roles, and configure Option Valuation limits, with a round the clock monitoring system that sends alerts in the event of a breach.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1.  Data Sources
                    - Derivative Trades
                    - Market Prices
                    - Interest Rates
                    - Instrument Attributes

            2.    Frequency
                    - On Demand

            3.    Pre-Built Model
                    - Option Valuation

            4.    Complexity
                    - High
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Consolidates option data from C/ETRM, broker system, market data providers and spreadsheets

            2. Create option portfolios to run valuation

            3. Calculation of price volatility to be used in option valuation

            4. Use Black Scholes model to run valuation

            5. Calculate option value and Greeks – Delta, Gamma, Rho, Theta & Vega

            6. Add additional user defined fields to customize reports

            7. Alerts and monitors to signal breaches on position and prices

            8. Track changes and movement over a period
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Multiple portfolios with Option Valuation - View and compare option valuation of multiple portfolios with different trade set underlying.

            2. Compare historical Option valuation run overtime and view trends

            3. Monitor the hard and soft risk limits set on the Option Valuation results to check on hard and soft risk breaches and see utilization.
            """.black.size(17)
        )
        
        //====================================================================================================
        let diseaseIdentification = ("Click and ascertain if Plant/Crop is infected with disease \n\n".black.size(17)
            +   """
            \nRole
                - Role Farmer/Grower,Liaison Officer,Field Agents\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture, Food and Beverage\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nUser will be able to click a photo or upload from gallery, the image of the plant/crop. Intelligence engine runs disease identification model to ascertain if Threat is found or not.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1.    Frequency
                    - Online

            2.    Complexity
                    - High
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. The disease identification model has been trained over images of healthy and infected stems/plant.

            2. The model uses convolutional neural network, one of deep neural network architectures to learn the patterns in the healthy and infected images. Based on the learning it classifies new observations as infected or healthy.

            3. The model gives probabilities of the stem being infected or healthy based on the image of the stem/plant and classifies it in one of the two classes based on a threshold of 0.8. For example - Only when the probability of stem/plant being infected based on its image is greater than 0.8 the stem/plant is classified as Threat Found.
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Images uploaded will get appended with disease identification results.
            """.black.size(17)
        )
        
        //====================================================================================================
        let cashFlow = ("Cash Flow app for more accurate projected and predicted finance by estimating payment due date from business partners and analyzing history of their payment behavior.\n\n".black.size(17)
            +   """
            \nRole
                - Analyst, Category Manager, CFO, Finance Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture: Grains
                - Softs: Coffee, Sugar
                - Dairy
                - Energy: Gas, Crude and Refined Oil, Biofuel
                - Metals\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nThe Cash Flow app allows you to project cash flow by estimating payment dates based on payment terms and shipment status. It also lets you predict payment dates from business partners by analyzing their past payment records using machine learning algorithms. The Cash flow app allows you to project cash flow by estimating payment dates based on payment terms and shipment status. It also lets you predict payment dates from business partners by analyzing their past payment records using machine learning algorithms.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            Projected cash flow analysis
            1. Data Sources
                - Physical trades

            2. Frequency
                - End of day

            3. Complexity
                - Simple

            4. Enrichments
                - 10

            Predicted cash flow analysis
            1. Data Sources
                - Physical trades

            2. Frequency
                - End of day

            3. Complexity
                - Complex
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Projected cash flow app estimates payment date based on payment term as mentioned in the contract and adding the credit days as per the payment term to the shipment date

            2. Analysis of payment history and pattern of payment behavior helps to get predicted payment date

            3. Net contract value on the predicted payment date is indicative of predicted cash flow
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Net cash flow on predicted payment date

            2. Net cash flow on estimated payment date

            3. Top 5 net receipts and payments by counterparties

            4. Cash flow ladder
            """.black.size(17)
        )
        
        //====================================================================================================
        let yieldForecast = ("Predict crop yields by geography based on the historical yield results and forecasted weather conditions. \n\n".black.size(17)
            +   """
            \nRole
                - Grower, Procurement Manager, Grower Service Provider\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture, Food & Beverage\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nThe Yield Forecast App takes into account historical crop data and weather forecast, to analyze actual vs. forecasted yield. The app also recommends best crop mix and sowing dates tailored to achieve next season's revenue and profitability goals.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Farm inputs and outputs
                - Historical weather
                - Forecasted weather data

            2. Frequency
                - As required.

            3. Pre-Built Model
                - None.
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Combines farm inputs and outputs data with weather data

            2. Applies machine learning on history of farm inputs, weather and outputs

            3. Predicts the farm yield for the upcoming season, given the weather forecasts and the farm inputs planned for the upcoming season

            4. Record and track changes

            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Predict average yield per hectare for a given location

            2. Understand the relative importance of farm and weather variables for achieving the desired yield

            3. View combinations of farm inputs to achieve best yield results
            """.black.size(17)
        )
        
        //====================================================================================================
        let cropIntelligence = ("Assess farm health using ideal growing conditions and output from other farms as benchmarks. Compare blocks within a farm by analyzing their differences. \n\n".black.size(17)
            +   """
            \nRole
                - Grower Service Provider\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nThe Crop Intelligence App provides a detailed farm health scorecard by comparing soil, weather, geographic and disease status of each paddock with ideal conditions. This app helps optimize farm interventions through early detection of concern areas for preventive and proactive action.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Geolocation of paddocks
                - Weather data
                - Soil data
                - Disease occurrence data

            2. Frequency
                - As required.

            3. Pre-Built Model
                - Crop Intelligence Model
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Combines information of soil, weather and disease occurrence with geolocation

            2. Scores a block on soil conditions, weather conditions, disease and geography, based on defined ideal parameters range. Calculates composite score by combining these component scores

            3. Tags a block as "needs immediate attention", "needs attention" or "fair" based on pre-determined score range

            4. Flexibility to modify the criteria for scoring, based on a given crop and its recommended growing conditions in a given region

            5. Alerts and monitors to signal breaches on component or composite scores of a block

            6. Track changes and movement over a period of time
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. View how the overall conditions of one farm compare against another

            2. Analyze how farm conditions have improved/ worsened on a month on month basis

            3. Identify farms and blocks that require attention.

            4. Deep dive into one farm. Compare conditions of one block against another.

            5. View how each of the underlying factors have changed on a month on month basis. For eg: Zinc content in soil, rainfall, temperature, disease outbreaks etc.
            """.black.size(17)
        )
        
        //====================================================================================================
        let diseaseRiskAssessment = ("Analyze risks posed by unfavorable weather and disease outbreaks on a crop, across locations.\n\n".black.size(17)
            +   """
            \nRole
                - Trader, Procurement Manager, Grower Service Provider\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture, Food & Beverage\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nThe disease risk assessment app lets you hedge procurement risks and prioritize pest management advisory by assigning risk classification for areas and associated trade contracts, based on historic disease occurrences and weather conditions.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Physical trades
                - Disease occurrence history
                - Weather

            2. Frequency
                - As required.

            3. Pre-Built Model
                - Compound Risk Model
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Combines disease history and weather data

            2. Assigns disease risk scores to locations based on counts and intensities of reported diseases

            3. Assigns weather risk scores to locations by comparing actual weather conditions against ideal growing conditions recommended for the crop

            4. Calculates compound risk by combining disease and weather risk scores

            5. Flexibility to modify weather risk calculations depending upon the crop, variety and recommended growing conditions

            6. Flexibility to define disease intensities depending upon the potential damage associated with a given disease

            7. Flexibility to modify the weightages for disease and weather risk scores in the compound risk score

            8. Alerts and monitors to signal breaches on open trade contracts by risk category, location and delivery month

            9. Track changes and movement over a period of time
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. View location wise compound, disease and weather risk

            2. Deep dive into the counts and intensities of plant diseases reported across locations

            3. Analyze seasonality of compound, disease and weather risk

            4. View overall volume and value of trade contracts, by risk categories

            5. Deep dive into trade contracts by risk category, location and delivery month
            """.black.size(17)
        )
        
        //====================================================================================================
        let basisAnalysis = ("Basis Analysis for more profitable trading by comparing all possible opportunities in the market and portfolio. \n\n".black.size(17)
            +   """
            \nRole
                - Trader\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture: Grains
                - Softs: Coffee, Sugar
                - Dairy
                - Energy: Gas, Crude and Refined Oil, Biofuel
                - Metals\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nView past and forward movements of basis by commodity, location and location groups. This app allows users to minimize risks and leverage opportunities by limiting exposure with timely visibility and prompt alerts on major changes in basis. The app simulates 'what-if' positions, giving traders visibility into potential impact on P&L.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """

            1. Data Sources
                - Physical trades
                - Futures, Cash and Basis Prices from TR
                - Historical prices from TR
                - Sentiment data from TR

            2. Frequency
                - End of day and/or near real time

            3. Pre-Built Model
                - Position and Mark to Market

            4. Complexity
                - Simple

            5. Enrichments
                - 10
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Consolidates position from CTRM and multiple spreadsheets

            2. Conversion of units and currencies to base unit for reporting

            3. View historical and forward price trends

            4. Add additional user defined fields to customize reports and build user defined hierarchies

            5. Flexibility to support regional as well as a global view

            6. Alerts and monitors to signal breaches on position and prices

            7. Track changes and movement over a period of timeage is greater than 0.8 the stem/plant is classified as Threat Found.
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. View summary of basis exposure by month, change in basis exposure by grade

            2.Monitor net basis exposure by month

            3.View historical movement of cash prices Vs futures prices

            4.Set monitor to alert when basis is between a user defined range

            5.View average historical price on contracts and compare against the market to monitor effectiveness
            """.black.size(17)
        )
        
        //====================================================================================================
        let freightExposure = ("View overall freight exposure and hedge accurately and effectively. \n\n".black.size(17)
            +   """
            \nRole
                - Trader\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture: Grains
                - Softs: Coffee, Sugar
                - Dairy
                - Energy: Gas, Crude and Refined Oil, Biofuel
                - Metals\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nThe Freight Analysis App lets you automate freight exposure reports across global and regional business units. It allows users to view net exposure by combining FFA with freight exposure.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Physical trades
                - FFA trades
                - Freight Prices from excel upload

            2. Frequency
                - End of day and/or near real time

            3. Pre-Built Model
                - Freight Exposure

            4. Complexity
                - Simple

            5. Enrichments
                - 5
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Consolidates position from CTRM, broker system, and multiple spreadsheets

            2. Conversion of units and currencies to base unit for reporting

            3. Flexibility to define routes and lookup instruments associated with hedging

            4. View historical and forward price trends

            5. User defined rules for hedging strategy

            6. Add additional user defined fields to customize reports

            7. Flexibility to support regional as well as a global view

            8. Alerts and monitors to signal breaches on position and prices

            9. Track changes and movement over a period of time

            10. Monitor freight price movement
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Freight expsoure by route and instrument

            2. View net exposure by route and instrument

            3. Monitor to identify maximum change in exposure by route and instrument

            4. Monitor to view if market prices are within a user defined range

            5. View expsoure movement over a period of time to view trends
            """.black.size(17)
        )
        
        //====================================================================================================
        let logisticsOperationsAnalysis = ("Track logistics operations in near real time for quick response to delays and deviations. \n\n".black.size(17)
            +   """
            \nRole
                - Operations Manager, Supply Chain Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture, Biofuels, Food and Beverage, Industrial Manufacturing, Metals, Oils\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nThe Logistics Operations Analysis App lets you track goods movement and delays, deviations, and accrual adjustments for change of routes and paths. It also allows you to analyze KPI by logistics company, its route, origin, destination and more.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
                1. Data Sources
                    - Planned Movements
                    - Ticket Information
                    - Freight Movement Cost Matrix

                2. Frequency
                    - On demand

                3. Complexity
                    - Medium

                4. Enrichments
                    - 8
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Delay and Deviation identification and notification

            2. Accrual adjustment calculations for movements that have difference between plan vs actual movements

            3. Dead Freight calculations

            4. Tracks and spots overall outliers in routes, freight providers, logistic counter parties based on frequency of recurring logistic issues

            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Freight accrual adjustment

            2. Goods movements, delays and deviations

            3. Load time tracking

            4. Route, freight provider, logistic counter party KPIs
            """.black.size(17)
        )
        
        //====================================================================================================
        let reconciliation = ("Standardize, control and streamline all reconciliations. Match payments, adjustments, receipts, contracts, stocks and commissions to the last cent. \n\n".black.size(17)
            +   """
            \nRole
                - Analyst, CFO, Finance Manager, Trader, Risk Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture, Biofuels, Food and Beverage, Industrial Manufacturing, Metals, Oils, Gas\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nThe Reconciliation App undertakes complex grouping, matching and mathematical calculations to reconcile trades, stocks, commissions and more, from disparate systems.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - CTRM/ETRM Trading Application
                - Accounting Application
                - Broker Files

            2. Frequency
                - EOD and EOM

            3. Complexity
                - Medium

            4. Enrichments
                - 23
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Complex grouping and mapping of GL/ Accounts from all the various systems for easy comparison.

            2. Bring forward previous month details and append delta records of current period to perform the reconciliation process.

            3. Complex mathematical calculations run in the reconciliation process.
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Breaks and differences identification made easier

            2. Save time and cost thereby reducing EOD and EOM time pressure

            3. Replace all manual recon activities with one-click Recon app

            4. Identify and avoid fraudulent activities, manual or system integrations errors in journals
            """.black.size(17)
        )
        
        //====================================================================================================
        let creditRisk = ("Monitor counterparty credit exposure\n\n".black.size(17)
            +   """
            \nRole
                - Risk Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Ags\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nConsolidate position across counterparties and their associated credit exposures.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Credit Exposure from spreadsheet
                - Counterparty ratings from rating agencies (spreadsheet)
                - Position by Counterparty from CTRM
                - Market Price

            2. Frequency
                - On demand

            3. Complexity
                - Simple

            4. Enrichments
                - 5
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Consolidate position data from CTRM systems and spreadsheets across all business units, across all counterparties

            2. View position and mark to mark by counterparties and ratings

            3. Set up limits to monitor credit exposure by counterparty groups and as well as individual cp's

            4. Monitor risk breaches and risk limit utilization
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Credit Limit Management

            2. Credit Insights

            3. Credit Exposure

            4. Market Prices
            """.black.size(17)
        )
        
        //====================================================================================================
        let thomsonReutersApp = ("Eka connectors to Thomson Reuters bring in end-of-day data, intraday and historical prices from Thomson Reuters, has extensive coverage of market data from leading global exchanges for ags, metals, power, natural gas, oil, FX, interest rates, freights. In addition to market prices Eka has company fundamentals, corporate actions and ratings data. It also covers reference data feeds for FATCA, MIFID regulatory reporting. These feeds provides ability to assess counterparty risk, corporate structures, country of risk and counterparty's regulatory compliance status.\nMarket prices coupled with trades data and alternative data sets such as weather, crop production, company fundamentals, social media, news can be leveraged by commodity market participants for improved decision making and gain competitive advantage against their peers in the industry. \n\n".black.size(17)
            ).append("\n\nThomson Reuters App in Eka enable the following functionalities for commodities market:\n".black.size(17)
                
                +   """
            1. Basis Analysis for various agricultural commodities

            2. Yield Predictions for Wheat

            3. Global Buy insights for Procurement

            4. Hedging Analysis

            5. VaR Stress Analysis

            6. P&L Analysis

            7. Monitoring Global Risk Limits
            """.black.size(17)
        )
        
        //====================================================================================================
        let hyperLocalWeather = ("Based on weather forecast have the right amount of water available. Also know when to and when not to put the fertilizer/pesticides, so as to not drain them due to impending rainfall forecast \n\n".black.size(17)
            +   """
            \nRole
                 Trader, Grower Services\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture, Biofuels, Food and Beverage, Oil and Gas, Power, Industrial Manufacturing\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \n- Hourly and Daily Forecast
            - Rainfall, Temp, Wind Speed, Sunshine, Cloud Cover are some of the parameters covered
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1.    Data Sources
                    - Daily Weather Forecast
                    - Hourly Weather Forecast

            2.    Frequency
                    - Online

            3.    Complexity
                    - Low
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. For the User defined location, ascertains the geo-codes to fetch daily and hourly weather information from the closest weather station.
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Today’s Forecast

            2. Historical Weather
            """.black.size(17)
        )
        
        //====================================================================================================
        let powerSpreadAnalysis = ("Analyse electricity spreads and achieve the maximum profitability on power stations by producing power for the customer demand and participate in the wholsale trading market. \n\n".black.size(17)
            +   """
            \nRole
                - Trader\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Energy\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nAsset Classes
                - Power, Gas, Coal\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nThe Power Spread Analysis provides an overveiw on Spreads(including Clean Spreads), Merit order of Power Plant and Wholesale Market Activity to help trader obtain the maximum margin on Power Plant while meeting the the forecasted demand and supply and possiblity to trade short or surplus capacity.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1.    Data Sources
                        - Power Plant Data: Power Output, Emissions Intensity, Efficiency %
                        - Market Prices from TR - Power, Gas, Coal, EUA, CER
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Calculate Spark Spread, Dark Spread including Clean Spreads.

            2. Calculate Margins for each Power Station.

            3. Consolidate all the data together easily to calculate the merit order of their power stations across the market forward curve to optimise the fuel to power spread analysis and profit from the wholesale market conditions.

            4. Provides analysis on forecasted Market Demand and Plant Output Supply.

            5. Monitoring – Alerts and Notifications can be set up for users to manage any breaches.
            
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Spreads at Baseload

            2. Clean Spreads at Baseload

            3. Merit Order of Plants

            4. Plant Combined Output on each Month

            5. Market Demand and Supply

            6. Price Trends – Power, Gas, Coal, EUA, CER
            """.black.size(17)
        )
        
        //====================================================================================================
        let qualityArbitrageAnalysis = ("Quality arbitrage opportunity to allocate stocks to Sale Contract to achieve better Profits and Margins. \n\n".black.size(17)
            +   """
            \nRole
                - CRO, CFO, Trader, Risk Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture, Biofuels, Food and Beverage, Oil and Gas, Power, Industrial Manufacturing\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nTrader’s miss opportunities due to lack of full visibility of quality in the supply chain, and possibility of doing a quality arbitrage. The app helps Trader increase profit and margin.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Silo Information
                - Quality P/D Schedule
                - Quality Reports
                - Sales Contracts

            2. Frequency
                - Online

            3. Complexity
                - High
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Fetches the Unallocated Stocks in a Silo, and studies the Quality results to ascertain the Stocks that can qualify for another Grade. Such Stocks are picked up and additional premium is calculated to arrive at the Arbitrage Opportunity.
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Quality Arbitrage Opportunity
            """.black.size(17)
        )
        
        //====================================================================================================
        let vesselManagement = ("Explore the optimum trade strategy based on shipping times, commodity prices and costs such as shipping costs, liquification costs, regasification costs, throughput costs, etc.\nFind out the best voyage strategy based on factors such as shipping costs, charter costs, bunkering charges, boil-off rates, demurrage rates, shipping times etc. to determine which voyage strategy would deliver maximum profits.\nGet complete view of your vessels, their status and location and possible delays to plan vessel strategy efficiently. \n\n".black.size(17)
            +   """
            \nRole
                - Trader, Operations Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Energy: LNG (Liquified Natural Gas)\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nVessel Management app allows users to analyze and compare Revenues and P&L for different trading strategies (e.g. spot sale vs. shipping to different ports) and get vessel status for self-owned as well chartered vessels to plan voyages in advance and save idle time.\nThe app also allows you to compare different voyage strategies (considering different rates such as fuel costs, port charges, bunkering charges etc.) to decide on the optimum voyage strategy.\nFinally, it allows users to view vessel status, their last location, estimated voyage time (for in-voyage vessels) and possible delays. This enables users to plan their strategy on vessels for future voyages.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Physical trades
                - Shipping Times
                - Shipping Costs
                - Additional Charges (Bunkering, liquification, regasification, etc.)
                - Vessel Details (Status, source, destination, last known location, etc.)

            2. Frequency
                - On demand

            3. Complexity
                - Simple

            4. Enrichments
                - 15
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Calculate Margin and P&L for different trade strategies – Bring together trade data, costs and and price information to suggest to user the best trading strategies to use.

            2. Dynamic Cost Calculation – Based on ship speeds, current position and distance, predict delays, and related demurrage costs, if any. Similarly, based on boil-off rates and voyage strategy, calculate bunkering charges, if applicable.

            3. Highlight the optimum voyage strategies based on profitability, which is calulcated by taking multiple factors and scenarios into consideration. Optional costs such as demurrage and bunkering are calulcated on case to case basis based on the scenario selected.
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Cost Information

            2. Voyage time information

            3. P&L for different trading strategies

            4. Vessel Information

            5. In-Voyage vessel summary (current location, last known port, ETA etc.)

            6. Spend and P&L for different voyage strategies (based on fuel selection)
            """.black.size(17)
        )
        
        //====================================================================================================
        let invoiceAging = ("Track payment behaviour of counterparties, monitor exposure and set alerts for counterparties credit breaches.\n\n".black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Open invoices from transaction systems
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Compute highest overdue amounts and counterparties with highest exposure

            2. Compute invoice aging ranges >30,30-60,60-90 or more

            3. Alerts when counterparty breaches overdue invoice limits
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Highest overdue amount

            2. Total Overdue

            3. Invoice overdue limit breaches by counterparties

            4. Top 10 counterparties by overdue amount and payment delays

            5. Invoice Aging Report with counterparties that have overdue amounts in >30, 30-60,60-90 and >90 aging ranges
            """.black.size(17)
        )
        
        //====================================================================================================
        let plantOutage = ("Track and analyze impact of plant outages on volume and value. \n\n".black.size(17)
            +   """
            \nRole
                - Risk Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Refined Products\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nConsolidate position across business units and view impact due to external factors like planned and unplanned outages and take corrective action in near real time.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Historical Plant outages from TR
                - Physical positions by refinery
                - Hedges

            2. Frequency
                - On Demand

            3. Pre-Built Model
                - Refinery Outage

            4. Complexity
                - Simple

            5. Enrichments
                - 5
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Consolidate position data from multiple ETRM systems and spreadsheets across all business units, across all geos

            2. Cleanse, transform and apply business rules to get a single consolidated dashboard to view position

            3. Classify refineries as stable, moderately stable, unstable using historical outage data and custom defined rules

            4. Combine position data with refinery outage to see how much of my position falls into the above classification

            5. Alerts and limits to track any market activity and sudden spikes in demand and supply shortage

            6. Add what-if to see impact of shortfall on P&L
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Historical analysis of outages

            2. Consolidated position

            3. View positions at risk based on refinery status

            4. View market trends

            5. View hedge policy and deviations from the same
            """.black.size(17)
        )
        
        //====================================================================================================
        let emissionsHedging = ("Real time visibility on Carbon Portfolio and tactful insights enabling right hedging decision.\n\n".black.size(17)
            +   """
            \nRole
                - Portfolio Manager, Analyst – Carbon Desk\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Energy\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nThe Emissions Hedging app provides a real time visibility on Co2 Positions and underlying exposure, taking Inventory(Stock) and Registry details into account. The Co2 exposure is calculated for current and forward years. Trader can buy extra allowances or hedge EUA or swap CER for EUA to make money and cover the Co2 exposure.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            
            1. Data Sources
                - Power Trades indicating demand and supply from Market.
                - Market Prices from TR – EUA, CER
                - Co2 Trades indicating Stock, Registry, Hedges.
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Consolidate all the data together easily from different systems to calculate the exposure and hedges made to cover them.

            2. Provide aggregated Co2 positions to help forward planning.

            3. Alerts and Notification on Emissions Allowances Price changes, Positions breach.
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Carbon Portfolio Dashboard for Management level

            2. Co2 Hedges and Stock Details

            3. Aggregated Co2 Positions

            4. Price Trends : EUA vs CER
            """.black.size(17)
        )
        
        //====================================================================================================
        let customerConnect = ("Reach out, connect and give near real time information access to your Customers. \n\n".black.size(17)
            +   """
            \nRole
                - Trader\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture, Biofuels, Food and Beverage, Industrial Manufacturing, Metals, Oils, Gas\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nThe Customer Connect App enables Counterparties and Business Partners to easily, quickly and seamlessly view all the required information across Offers, Sales Contracts, Tickets and Deliveries and Invoices and Payments.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - CTRM/ETRM Trading Application
                - Ticketing Application
                - Accounting Application
                - Invoicing and Banking Application
                - External Market Data Provider

            2. Frequency
                - Online

            3. Complexity
                - Low

            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Retrieves, filters and based on the Counter Party/ Business Partner generates Insights and Alerts for Offers, Existing Contracts and their Status, Tickets/Transportation Details, and Sales and Invoice/Payments data with the Company.
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Offers

            2. Open Sale Contracts and Detailed Pricing and Quantity information

            3. Upcoming Deliveries

            4. Invoices and Payments status

            5. Market Prices
            """.black.size(17)
        )
        
        //====================================================================================================
        let supplyDemand = ("Demand and Vendor analysis for manufacturing, enabling better planning and strategy. \n\n".black.size(17)
            +   """
            \nRole
                - CFO, Risk Manager\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Food and Beverage, Industrial Manufacturing\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nVendor, Inventory and Demand scoring components definition and weightage
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Data Sources
                - Inventory
                - Demand and Supply Information
                - Vendor and Credit Information

            2. Frequency
                - Online

            3. Complexity
                - High
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Every entity is treated independently and a polynomial is fit to generate as many model as number of entities, to generate demand forecasting.

            2. In addition, Dead Stock Analysis, Scoring and EoQ computation is undertaken to arrive and score demand numbers.
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Vendor Analysis

            2. Inventory Analysis

            3. Strategy Analysis
            """.black.size(17)
        )
        
        //====================================================================================================
        
        let priceTrendAnalysis = ("Click and ascertain if Plant/Crop is infected with disease \n\n".black.size(17)
            +   """
            \nRole
                - Role Farmer/Grower,Liaison Officer,Field Agents\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            + "\n".backgroundColor(.white)
            
            +   """
            \nSegment
                - Agriculture, Food and Beverage\n\n
            """.backgroundColor(Utility.cellBorderColor).size(17)
            
            +   """
            \nUser will be able to click a photo or upload from gallery, the image of the plant/crop. Intelligence engine runs disease identification model to ascertain if Threat is found or not.
            """.black.size(17)
            ).append("\n\n\nTechnical Specifications\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1.    Frequency
                    - Online

            2.    Complexity
                    - High
            """.black.size(17)
            ).append("\n\n\nIntelligence Engine\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. The disease identification model has been trained over images of healthy and infected stems/plant.
            2. The model uses convolutional neural network, one of deep neural network architectures to learn the patterns in the healthy and infected images. Based on the learning it classifies new observations as infected or healthy.
            3. The model gives probabilities of the stem being infected or healthy based on the image of the stem/plant and classifies it in one of the two classes based on a threshold of 0.8. For example - Only when the probability of stem/plant being infected based on its image is greater than 0.8 the stem/plant is classified as Threat Found.
            """.black.size(17)
                
            ).append( "\n\n\nKey Insights\n\n".color(Utility.appThemeColor).size(24)
                
                +   """
            1. Images uploaded will get appended with disease identification results.
            """.black.size(17)
        )
        
        //====================================================================================================
        
        
        switch self.app.name{
            
        case "Regulatory and Compliance" :
            attributedTextView.attributer = regulatoryAndCompliance
            
        case "Position and Mark to Market":
            attributedTextView.attributer = positionAndMarkToMarket
            
        case "P&L Explained":
            attributedTextView.attributer = pAndlExplained
            
        case "Trade Finance":
            attributedTextView.attributer = tradeFinance
            
        case "VaR":
            attributedTextView.attributer = VaR
            
        case "Risk and Monitoring":
            attributedTextView.attributer = riskAndMonitoring
            
        case "Purchase Analysis":
            attributedTextView.attributer = purchaseAnalysis
            
        case "Procurement Analysis":
            attributedTextView.attributer = procurementAnalysis
            
        case "Inventory Analytics":
            attributedTextView.attributer = inventoryAnalytics
            
        case "Plan Performance":
            attributedTextView.attributer = planPerformance
            
        case "Pre-Trade Analysis":
            attributedTextView.attributer = preTradeAnalysis
            
        case "Farmer Connect":
            attributedTextView.attributer = farmerConnect
            
        case "Disease Prediction":
            attributedTextView.attributer = diseasePrediction
            
        case "Options Valuation":
            attributedTextView.attributer = optionsValuation
            
        case "Disease Identification":
            attributedTextView.attributer = diseaseIdentification
            
        case "Cash Flow":
            attributedTextView.attributer = cashFlow
            
        case "Yield Forecast":
            attributedTextView.attributer = yieldForecast
            
        case "Crop Intelligence":
            attributedTextView.attributer = cropIntelligence
            
        case "Disease Risk Assessment":
            attributedTextView.attributer = diseaseRiskAssessment
            
        case "Basis Analysis":
            attributedTextView.attributer = basisAnalysis
            
        case "Freight Exposure":
            attributedTextView.attributer = freightExposure
            
        case "Logistics Operations Analysis":
            attributedTextView.attributer = logisticsOperationsAnalysis
            
        case "Reconciliation":
            attributedTextView.attributer = reconciliation
            
        case "Credit Risk":
            attributedTextView.attributer = creditRisk
            
        case "Thomson Reuters App":
            attributedTextView.attributer = thomsonReutersApp
            
        case "Hyper Local Weather":
            attributedTextView.attributer = hyperLocalWeather
            
        case "Power Spread Analysis":
            attributedTextView.attributer = powerSpreadAnalysis
            
        case  "Quality Arbitrage Analysis":
            attributedTextView.attributer = qualityArbitrageAnalysis
            
        case "Vessel Management":
            attributedTextView.attributer = vesselManagement
            
        case "Invoice Aging":
            attributedTextView.attributer = invoiceAging
            
        case  "Plant Outage":
            attributedTextView.attributer = plantOutage
            
        case  "Emissions Hedging":
            attributedTextView.attributer = emissionsHedging
            
        case  "Customer Connect":
            attributedTextView.attributer = customerConnect
            
        case "Supply Demand":
            attributedTextView.attributer = supplyDemand
            
        case "Price Trend Analysis":
            attributedTextView.attributer = priceTrendAnalysis
            
        default:
            attributedTextView.attributer = "Not Applicable".black.size(17)
            
        }
        
        
    }
    
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
