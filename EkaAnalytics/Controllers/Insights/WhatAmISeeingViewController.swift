//
//  WhatAmISeeingViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 22/02/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class WhatAmISeeingViewController: GAITrackedViewController {
    
    @IBOutlet weak var attributedTextView:AttributedTextView!
    
    var app:App!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.whatAmISeeing
        
        let regulatoryAndCompliance =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
        EU - EMIR - Sample Derivative Transactions
        US - CFTC 204 - Physical Transactions Grain
        Commodity
        Swiss – FinFrag – Sample Derivative
        Transactions\n\n
        """.black.size(17)
                +
                "Intelligence Engine :\n".color(Utility.appThemeColor).size(18)
                +
                """
        EMIR - Report as Unavista spec with Deal Life
        Cycle
        CFTC 204 - Grain Position summary as per
        CFTC Spec
        FinFrag – Report as per SIX TR Spec including
        Deal life cycle\n\n
        """.black.size(17)
                +
                "Dataset\n".color(Utility.appThemeColor).size(18)
                +
                """
        > EMIR - Sample EU
        > FinFrag - Swiss Derivatives Transaction
        > US CFTC 204 - Physicals position exposure output
        """.black.size(17)
        
        //====================================================================================================
        
        let positionAndMarkToMarket =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
        Open Physicals Contracts, Derivative
        Contracts and Inventory data\n\n
        """.black.size(17)
                +
                
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                """
        Daily Position &amp; Price exposures, Mark to
        Market and Unrealized P&amp;L factoring in
        rollover for expired futures contracts.
        Exposure modelling allows for risk
            distribution across delivery period and is
        reported in terms of As-Is, Input/ Output
        Processing Product or Cross Hedging.\n\n
        """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
        Open Physical and Derivative trade Data
        Inventory Data
        Basis Prices and Futures Data
        Quality and Location Differentials Data
        Fx Rates
        Plant Conversion Yield Factors
        Cross Hedge Ratio
        """.black.size(17)
        
        //====================================================================================================
        
        let pAndlExplained =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Previous and Current period contract,
            inventory, execution, market and
            invoice/accrual data\n\n
            """.black.size(17)
                +
                
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Taking every variable that impacts Position
            and P&amp;L and measuring its standalone
            impact on the change in Position and P&amp;L.
            This computation is triggered for each of the
            variables, while maintaining other variables
            as constant, resulting in 60 attribution
            buckets.\n\n
            Attribution buckets across Market
            Movements, New Contracts, Contract
            Changes, Executions, Processing, Accruals
            and Invoicing.\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Physicals and Derivatives Trades
            Mark to Market
            Market Prices
            Execution Details
            Accrual Details
            """.black.size(17)
        
        //====================================================================================================
        
        let tradeFinance =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Bank Cost Quotations and Trade Finance
            Scenarios\n\n
            """.black.size(17)
                +
                
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Most Cost Effective trade finance
            opportunities for Loans and LCs, by
            generating all the Banks opportunities based
            on its Financing, Advising, Negotiating and
            Confirming Roles.\n\n
            """.black.size(17)
        
        //====================================================================================================
        
        let VaR =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Trade information such as physical
            trades, futures, options, currency
            forwards. Historical price, FX rates, and
            interest rates data from different
            sources. User defines VaR parameters
            such as VaR Horizon, historical Price
            period to be used, VaR Confidence levels,
            number of iterations (for Monte Carlo
            Simulation method) and so on.\n\n
            """.black.size(17)
                +
                "Filtered On:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Portfolios created dynamically by users
            based on their requirements. A portfolio
            can contain trades of different types
            filtered on one or more filter criteria (e.g.
            Profit Center, Strategy, Product)\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Volatility and Correlation between
            different curves, asset classes and
            maturities.VaR can be created using
            different methods like Parametric
            (Variance-Covariance), Monte Carlo
            Simulation and Historical Simulation
            methods. Other measures such as
            Shortfall, Undiversified VaR, Standard
            Deviation of P&amp;L, Marked to Market
            (MTM) Value and P&amp;L frequency
            distribution are also returned by the
            engine.\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Trades
            Market Data
            """.black.size(17)
        
        //====================================================================================================
        
        let riskAndMonitoring =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Multiple measures for monitoring
            such as P&amp;L value, VaR, Position Exposures,
            Market Prices and more\n\n
            """.black.size(17)
                +
                
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Compare set limits
            against computed output values (computed
            by other Apps or other sources) to report
            threshold and limit breaches\n\n
            """.black.size(17)
        //====================================================================================================
        
        let purchaseAnalysis =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Quality Properties, Contracts/Trades, Market
            data - Price, Market data -FX, Master Data,
            Landfill Cost, Charges(TC/RC/Penalties) and
            Interest Rate\n\n
            """.black.size(17)
                +
                "Filtered On:\n".color(Utility.appThemeColor).size(18)
                +
                
                "Entire data is used to do calculations\n\n".black.size(17)
                +
                
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            -Calculate Raw Material Margin (RMM) in
            real-time for a combination of Quality,
            Feeding Point and Supplier.\n
            -Provides result of RMM for selected
            qualities on latest contracts from different
            suppliers if the ore is processed in different
            feeding points of smelters.\n\n
            """.black.size(17)
                
                +
                "Simulation Output:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Ability to simulate RMM calculation in real-
            time and thereby allow comparison of RMM
            results across multiple scenarios by shocking
            one or more of the below input parameters:
            · Quality assay values by metals
            · Contract info (Payable) by suppliers
            · Charges (TC/RC/Penalty) by suppliers
            · Market prices of metal prices across
            different time horizons
            · FX rates across different time horizons\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Quality (Assay Information), Contract,
            Processor Data (Smelter &amp; Feeding Point
            Properties), Other Costs (Landfill Costs, etc),
            Market Prices for traded elements across
            different purchasing options/time horizons
            like spot, budget and Long term.
            FX Rates
            """.black.size(17)
        //====================================================================================================
        
        let procurementAnalysis =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Plan, Cost Model, Coverage and Spend
            Information for multiple Items (Raw
            Materials), Plants and Suppliers.\n\n
            """.black.size(17)
                +
                "Filtered On:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Portfolios created dynamically by users
            based on their requirements. A portfolio
            can contain different items filtered on one
            or more filter criteria (e.g. Plant, Buyer,
            Commodity, Category, etc.)\n\n
            """.black.size(17)
                +
                
                "Computed:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Coverage Percentages, Spend (Actual,
            Covered, Uncovered, Forecasted)
            and Variance (From Plan) for different
            items. The numbers can be combined to get results at category, sub-
            category, plant, etc. levels. In
            addition, the simulation module allows
            users to simulate probable market or
            business scenarios and see their
            impact on key procurement
            measures.\n\n
            """.black.size(17)
                
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Item &amp; Plan Data
            Cost Model DataCoverage
            Information
            """.black.size(17)
        //====================================================================================================
        
        let inventoryAnalytics =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Market prices, actual delivery, nominations
            data and inventory\n\n
            """.black.size(17)
                +
                "Computed:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Predictive analysis allows users to see likely
            trend based on past pattern and helps
            analysing inventory COG VS market to make
            better buy and sell decisions. Computes
            projected inventory helping traders in
            decision making and optimizing inventory
            position for profits. Inventory Limits helps to
            track inventory and notify.\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            DS- Physicals
            DS- Market Prices
            DS Inventory Actuals
            DS Inventory Nominations
            """.black.size(17)
        //====================================================================================================
        
        let planPerformance =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Operation Plan and Operation Actuals\n\n
            """.black.size(17)
                +
                "Computed:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Actulas data modelled and aggregated to match the granularity of Production Plan.Each Task,Equipment and Resource of the Operation Actuals tagged with the Operation Plan to get as-per-plan and deviations metrices.\n\n
            """.black.size(17)
                +
                "\n6 performance metrics:\n".color(Utility.appThemeColor).size(18)
                +
                """
            On-time,Off-Time,Planned Tonnage,Unplanned Tonnage,In-Sequence,Out-of-Sequence\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Operation Plan
            Operation Actulas
            Equipment,shift Roster and Delay
            Definitions
            """.black.size(17)
        //====================================================================================================
        let preTradeAnalysis =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Logistic Route and INCO Term mapping,Revised Volume functionally and Product Cost methodology with User input Pre-Trade Scenario,Routes and Costs.\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Suggests all possible logistic routes with their corresponding product locations.
            The app also calculates and suggests the Volume to offer based on logistic stowage and gives the best possible Offer/SalePrice and Margin.\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Pre-Trade Scenario
            >Logistic Routes and Freights
            >Product Costs
            >Custom Costs
            >Processing Costs
            >FX Rates
            >Finance Costs
            >Any Other Costs
            """.black.size(17)
        //====================================================================================================
        let farmerConnect =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Data available and stored in the transaction system,accounting system,spread sheets and ticket information system.\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Retrieves,filters and based on the Farmer preference,generates Insights and Alerts for Offers,Existing Contracts and their Status, Tickets/Transportation Details,and Sales and Invoice/Payments data with the Company.\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Price Sheet
            >Contract Information
            >Ticket Details
            >Accounting
            """.black.size(17)
        //====================================================================================================
        
        let diseasePrediction =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Historical Rust Incidence and Rust Severity with weather parameters\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            The model uses advance analytics agriculture feature engineering,which is modelled to factor in weather that impacts the plant,such as sunshine period,relative humidity,cloud cover,and other weather parameters.This with historical analysis such as seasonality,variety,location and other factors are modelled to bring out the Disease Prediction\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Weather Data Daily
            >Weather Data Hourly
            >Historical Disease Incidence Data
            """.black.size(17)
        //====================================================================================================
        let yieldForecast =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Multiple farm variables and normalized weather variables at each location\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Independent variables by means of Agriculture specific feature engineering.This was supplied to the Machine Learning algorithm,to create an ensemble model of weak learners that continually partitions to minimize residuals.\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Historical Production Data
            >Weather Data
            >Soil Data
            """.black.size(17)
        //====================================================================================================
        let cashFlow =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Past payment behaviour in addition to Current Open Contract Value,Payment terms,Shipment Status\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Predict Payment dates using historical trend analysis of the business partner.\n\n
            """.black.size(17)
        //====================================================================================================
        let cropIntelligence =
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Component of Farm Health, Weather and Soil Sub Components\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Using Machine Learning and Historical Analysis derive Farm Performance parameters that need immediate attention.\n\n
            """.black.size(17)
        //====================================================================================================
        let diseaseRiskAssessment =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Historical weather data across locations and forecasts,recommended growing conditions for the given crop,location wise history of disease occurrence and severity\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            >Uses machine learning model to compute the probability of disease outbreak in a given location based on history of incidences and forecasted weather
            >Assigns normalised weather risk scores to locations, by comparing actual weather with the recommended growing conditions
            >Assigns normalised disease risk scores to locations based on number and severity of incidences
            >Calculates a combined risk score for every location, by assigning user-defined weightages to weather and disease risk scores \n\n
            """.black.size(17)
        //====================================================================================================
        
        let basisAnalysis =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Basis Price and Futures Price for Wheat and Corn\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Daily Basis change percentages, average contract basis and market basis for corn and wheat\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Historical Basis Prices
            >Future
            """.black.size(17)
        //====================================================================================================
        
        let freightExposure =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            FFA Contracts, Freight Prices\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Freight Exposure calculated and Outliers detected for every route. In addition,real time limits and threshold tracking for every contract and route, and notifications/alerts sent.\n\n
            """.black.size(17)
        //====================================================================================================
        
        let logisticsOperationsAnalysis =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Dead Freight Quantity,Dead Freight,Deviation from Goods Movement Record,Ticket Information and Freight Costs\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Near-Real time tracking of Logistic movements for Deviations and Delays.Auto recalculations of Accurual Adjustments for such movements.\n\n
            """.black.size(17)
        //====================================================================================================
        let reconciliation =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Transaction,Accounting,ERP\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Data modelling and transformations to bring in transactions from each disparate sources to a common model to enable Reconciliations.Multiple variable across quantity,price and amount are taken up for Reconcillation.Non-reconciled records are brought out and highlighted.\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Transaction System Data
            >Accounting Data
            >ERP Data
            >Broker/Clearer Provided Data
            """.black.size(17)
        //====================================================================================================
        
        let creditRisk =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Counterparty Position and Mark to Market and Ratings\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            CP Credit Scores and credit exposure\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >As-Is-Position
            >Mark to Market
            """.black.size(17)
        //====================================================================================================
        let thomsonReutersApp =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Basic Curves,Market Prices,Risk Monitoring measures,Yield Forecast,COGS,Exposure,P&L,Forward Price Curves\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            >Computes day-to day Basis Price movements and identifies the locations with highest movement.
            >Compares average market basis and contract basis.
            >Compare set risk limits against computed output values(computed by other Apps or other sources)to report threshold and limit breaches
            >Computes P&L Chnage over time for Energy and Ags
            >Computes wheat yield predictions based on historical trends\n\n
            """.black.size(17)
        
        //====================================================================================================
        
        let hyperLocalWeather =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Weather Forecasting Information\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            For the User defined location,ascertains the geo-codes to fetch daily and hourly weather information from the closest weather station.\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Weather Forecast
            """.black.size(17)
        //====================================================================================================
        
        let powerSpreadAnalysis =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Market Prices of Power,Coal,Emissions and Gas,Plant Efficiency\n\n
            """.black.size(17)
                +
                "Filtered On:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Input Data is set to be region specific(EU or US)\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Calculate Theoretical value of Spark Spreads(including Clean),Dark Spreads(include Clean)
            Calculates Merit Order of Various Power Plant based on Margin and Efficiency(Heat Rate)to meet Market Demand and helps in Trading decision\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Market Prices - Power,Coal,Gas
            >Emissions(EUA/CER)
            >Emissions Intensity %
            >Plant Efficiency%
            """.black.size(17)
        //====================================================================================================
        
        let qualityArbitrageAnalysis =
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Quality P/D Schedule, Quality Reports and Stock/Silo Information\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Fetches the Unallocated Stocks in a Silo, and studies the Quality results to ascertain the Stocks that can qualify for another Grade. Such Stocks are picked up and additional premium is calculated to arrive at the Arbitrage Opportunity.\n\n
            """.black.size(17)
        //====================================================================================================
        
        let vesselManagement =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            LNG Cost Details such as Market Prices at different locations, liquification costs, regasification costs. Voyage details such as chartering rates for LNG vessels, shipping times between different ports, Ship capacities, ship status, etc for different trading strategies (spot sale, domestic resale, liquification and shipping) and shipping strategies (shipping to different ports, different fuel types used\n\n
            """.black.size(17)
                +
                "Filtered on:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Entire data is used to perform the calculations\n\n
            """.black.size(17)
                +
                    "Computed:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            The total revenue and Profit &amp; Loss (P&L) is calculated for different trading strategies, allowing user to choose the best to go with. Similarly, for all scheduled vessels, shipping costs (including possible demurrage and bunkering charges) are calculated and allows users to choose the best strategy to go with.\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Cost Details
            >Cost Details LNG Market Rates
            >Shipping Rates
            >Shipping Rates Chartering Rates
            >Bunkering Rates>Demurrage Rates
            >Ship Details
            >Ship/Vessel Status
            >Ship Details (Capacity, Boil Off Rates, Speeds, etc.)
            """.black.size(17)
        //====================================================================================================
        
        let invoiceAging =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Invoice Amounts by Counterparties\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Highest Overdue Amount,Total Overdue,Invoice Age Ranges\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Invoices
            """.black.size(17)
        //====================================================================================================
        
        let plantOutage =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            TR Market Prices, TR historical Plant Outage Data.\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Outage trend, Price trends, Positions at Risk based on Refinery Classification, Over and under hedge analysis.\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Sales commitments
            >Historical Refinery Outage Data
            """.black.size(17)
        //====================================================================================================
        
        let emissionsHedging =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Market Price of EUA, CER.
            Power and Co2 trades\n\n
            """.black.size(17)
                +
                "Filtered On:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Entire data is used for calculations\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Calculate Co2 exposure above capping limit.
            Calculate aggregated Co2 Position for forward year.
            Calculate Co2 Hedges and Stock(Inventory) Details\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Power trades to reflect demand and supply
            >Co2 trades to reflect Co2 emitted from Power plants
            >Co2 Inventory data
            """.black.size(17)
        //====================================================================================================
        
        let customerConnect =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Data available and stored in the transaction system, accounting system, spread sheets and ticket information system.\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Retrieves, filters and based on the Counter Party/ Business Partner generates Insights and Alerts for Offers, Existing Contracts and their Status, Tickets/Transportation Details, and Sales and Invoice/Payments data with the Company.\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Price Sheet
            >Contract Information
            >Ticket Details
            >Accountin
            """.black.size(17)
        //====================================================================================================
        
        let supplyDemand =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Inventory, Market trends, lead times and SoH forecasts\n\n
            """.black.size(17)
                +
                "Computed:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            Demand modelling and Historical analysis on Demand Vs Market Vs SoH trends. Consume and consolidate data to provide obsolescence percentage, inventory turn over ratio by product/part number.\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
                > Inventory Analysis
                > Demand Analysis
                > Vendor Analysis
                > Jet Fuel Prices
            """.black.size(17)
        //====================================================================================================
        
        let priceTrendAnalysis =
            
            "Used:\n".color(Utility.appThemeColor).size(18)
                +
                """
            Historical Rust Incidence and Rust Severity with weather parameters\n\n
            """.black.size(17)
                +
                "Intelligence Engine:\n".color(Utility.appThemeColor).size(18)
                +
                
                """
            The model uses advance analytics agriculture feature engineering,which is modelled to factor in weather that impacts the plant,such as sunshine period,relative humidity,cloud cover,and other weather parameters.This with historical analysis such as seasonality,variety,location and other factors are modelled to bring out the Disease Prediction\n\n
            """.black.size(17)
                +
                "Dataset:\n".color(Utility.appThemeColor).size(18)
                +
                """
            >Weather Data Daily
            >Weather Data Hourly
            >Historical Disease Incidence Data
            """.black.size(17)
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
