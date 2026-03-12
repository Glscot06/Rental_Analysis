Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Property Investment Calculator" Width="760" SizeToContent="Height" MinHeight="560"
        WindowStartupLocation="CenterScreen"
        Background="#F4F6F9">

<ScrollViewer VerticalScrollBarVisibility="Auto">
<Grid Margin="20">

    <Grid.ColumnDefinitions>
        <ColumnDefinition Width="2*"/>
        <ColumnDefinition Width="1*"/>
    </Grid.ColumnDefinitions>

    <!-- INPUT CARD -->
    <Border Background="White" CornerRadius="12" Padding="20" Margin="0,0,15,0">
        <StackPanel>

            <TextBlock Text="Property Details" FontSize="20" FontWeight="Bold" Margin="0,0,0,15"/>

            <TextBlock Text="Purchase Price"/>
            <TextBox Name="PurchasePrice" Height="30" Margin="0,0,0,10"/>

            <TextBlock Text="Zip Code"/>
            <TextBox Name="ZipCode" Height="30" Margin="0,0,0,10"/>

            <TextBlock Text="Interest Rate (%)"/>
            <TextBox Name="InterestRate" Height="30" Margin="0,0,0,10"/>

            <TextBlock Text="Mortgage Length (Years)"/>
            <TextBox Name="LoanYears" Height="30" Margin="0,0,0,10"/>

            <TextBlock Text="Down Payment (%)"/>
            <TextBox Name="DownPercent" Height="30" Margin="0,0,0,10"/>

            <TextBlock Text="Closing Costs (%)"/>
            <TextBox Name="ClosingPercent" Height="30" Margin="0,0,0,10"/>

            <TextBlock Text="Renovation Budget"/>
            <TextBox Name="RenovationCost" Height="30" Margin="0,0,0,10"/>

            <TextBlock Text="Estimated Monthly Rent"/>
            <TextBox Name="Rent" Height="30" Margin="0,0,0,20"/>

            <Button Name="CalculateBtn"
                    Content="Analyze Deal"
                    Height="40"
                    Background="#F0414D"
                    Foreground="White"
                    FontWeight="Bold"
                    BorderThickness="0"
                    Cursor="Hand"/>

        </StackPanel>
    </Border>

    <!-- RESULTS CARD -->
    <Border Grid.Column="1" Background="White" CornerRadius="12" Padding="20">

        <StackPanel>

            <TextBlock Text="Investment Summary" FontSize="20" FontWeight="Bold" Margin="0,0,0,20"/>

            <StackPanel Margin="0,5">
                <TextBlock Text="Down Payment" Foreground="Gray"/>
                <TextBlock Name="DownPaymentResult" FontSize="16" FontWeight="Bold"/>
            </StackPanel>

            <StackPanel Margin="0,5">
                <TextBlock Text="Closing Costs" Foreground="Gray"/>
                <TextBlock Name="ClosingCostResult" FontSize="16" FontWeight="Bold"/>
            </StackPanel>

            <StackPanel Margin="0,5">
                <TextBlock Text="Loan Amount" Foreground="Gray"/>
                <TextBlock Name="LoanAmountResult" FontSize="16" FontWeight="Bold"/>
            </StackPanel>

            <StackPanel Margin="0,5">
                <TextBlock Text="Total Cash Invested" Foreground="Gray"/>
                <TextBlock Name="TotalInvestmentResult" FontSize="16" FontWeight="Bold"/>
            </StackPanel>

            <StackPanel Margin="0,5">
                <TextBlock Text="Monthly Mortgage" Foreground="Gray"/>
                <TextBlock Name="MortgageResult" FontSize="16" FontWeight="Bold"/>
            </StackPanel>

            <StackPanel Margin="0,5">
                <TextBlock Text="Estimated Taxes + Insurance" Foreground="Gray"/>
                <TextBlock Name="TaxesInsuranceResult" FontSize="16" FontWeight="Bold"/>
            </StackPanel>

            <Separator Margin="0,15"/>

            <StackPanel Margin="0,5">
                <TextBlock Text="Estimated Monthly Cash Flow" Foreground="Gray"/>
                <TextBlock Name="CashFlowResult" FontSize="18" FontWeight="Bold" Foreground="#16A34A"/>
            </StackPanel>

            <StackPanel Margin="0,5">
                <TextBlock Text="Cash on Cash Return" Foreground="Gray"/>
                <TextBlock Name="CoCResult" FontSize="18" FontWeight="Bold"/>
            </StackPanel>

        </StackPanel>

    </Border>

</Grid>
</ScrollViewer>
</Window>
"@

$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load($reader)

$PurchasePrice=$Window.FindName("PurchasePrice")
$ZipCode=$Window.FindName("ZipCode")
$InterestRate=$Window.FindName("InterestRate")
$LoanYears=$Window.FindName("LoanYears")
$DownPercent=$Window.FindName("DownPercent")
$ClosingPercent=$Window.FindName("ClosingPercent")
$RenovationCost=$Window.FindName("RenovationCost")
$Rent=$Window.FindName("Rent")

$CalculateBtn=$Window.FindName("CalculateBtn")

$DownPaymentResult=$Window.FindName("DownPaymentResult")
$ClosingCostResult=$Window.FindName("ClosingCostResult")
$LoanAmountResult=$Window.FindName("LoanAmountResult")
$TotalInvestmentResult=$Window.FindName("TotalInvestmentResult")
$MortgageResult=$Window.FindName("MortgageResult")
$TaxesInsuranceResult=$Window.FindName("TaxesInsuranceResult")
$CashFlowResult=$Window.FindName("CashFlowResult")
$CoCResult=$Window.FindName("CoCResult")

$CalculateBtn.Add_Click({

$price=[double]$PurchasePrice.Text
$rate=([double]$InterestRate.Text)/100
$years=[double]$LoanYears.Text
$downPct=([double]$DownPercent.Text)/100
$closePct=([double]$ClosingPercent.Text)/100
$reno=[double]$RenovationCost.Text
$rent=[double]$Rent.Text

$downPayment=$price*$downPct
$closingCost=$price*$closePct
$loanAmount=$price-$downPayment
$totalInvestment=$downPayment+$closingCost+$reno

$monthlyRate=$rate/12
$months=$years*12

$mortgage=($loanAmount*$monthlyRate)/(1-[math]::Pow(1+$monthlyRate,-$months))

# Realistic taxes + insurance estimate
$propertyTaxRate=0.0102  # 0.99% average US property tax
$insuranceRate=0.009    # 0.9% average homeowners insurance
$taxInsurance=($price*$propertyTaxRate + $price*$insuranceRate)/12

$cashflow=$rent-$mortgage-$taxInsurance
$annualCashFlow=$cashflow*12

if($totalInvestment -gt 0){
$coc=($annualCashFlow/$totalInvestment)*100
}else{
$coc=0
}

$DownPaymentResult.Text="$"+[math]::Round($downPayment,2)
$ClosingCostResult.Text="$"+[math]::Round($closingCost,2)
$LoanAmountResult.Text="$"+[math]::Round($loanAmount,2)
$TotalInvestmentResult.Text="$"+[math]::Round($totalInvestment,2)
$MortgageResult.Text="$"+[math]::Round($mortgage,2)
$TaxesInsuranceResult.Text="$"+[math]::Round($taxInsurance,2)
$CashFlowResult.Text="$"+[math]::Round($cashflow,2)
$CoCResult.Text=[math]::Round($coc,2).ToString()+"%"

})

$Window.ShowDialog()
