# -*- coding: utf-8 -*-
"""
Created Dec 2018

Example of Python code: user-defined classes and exceptions;
input and output; input cleaning; recursion
"""

__author__ = "Michael Lawson"
__copyright__ = ""
__credits__ = ["Michael T. Lawson"]
__license__ = "CRAPL"
__version__ = "1.0.0"
__maintainer__ = "Michael T. Lawson"
__email__ = "mlawson2009@gmail.com"
__status__ = "Release"


import numpy as np


# define Python user-defined exceptions
class Error(Exception):
    """
    Base class for other user-defined exceptions
    """
    pass


class NotFloatError(Error):
    """
    Error indicating that value was expected to be a float
    """
    pass


class NotDivisibleError(Error):
    """
    Error indicating that value was expected to be a multiple of .05
    """
    pass


class NotPayinError(Error):
    """
    Error indicating that value was not a valid payin value
    """
    pass


class OutOfChangeError(Error):
    """
    Error indicating that machine is out of change
    """
    pass


class VendingMachine(object):
    """
    Class specifying the current status of the vending machine
    """
    def __init__(self, stock: np.array = np.array([25, 25, 25, 0, 0]),
                 balance_in: int = 0,
                 balance_out: int = 0,
                 amount_paid: int = 0,
                 state: str = "prompt",
                 quit_ind: bool = False,
                 payin_message: bool = False):
        """
        Constructor for VendingMachine
        Inputs:
        stock- number of [nickels, dimes, quarters, ones, fives] in machine
        balance_in - balance remaining to be inserted into the machine
        balance_out - balance remaining to be disbursed by the machine
        amount_paid - balance paid to machine this transaction
            (tracked for cancels)
        (balance_in, balance_out, amount_paid all store exact # of cents)
        state - state variable controlling the behavior of the machine;
            is derivable from balance_in and balance_out, but specified
            explicitly here for clarity; takes values
                "prompt" - prompt user for a price
                "payin" - collect money from user until fully paid
                    or transaction cancelled
                "payout" - return money to user until fully paid
                    or out of change
        quit_ind - boolean denoting whether vending machine should quit
        payin_message - boolean denoting whether initial instructions
            for payin should be printed
        """
        self.stock = stock
        self.balance_in = balance_in
        self.balance_out = balance_out
        self.amount_paid = amount_paid
        self.state = state
        self.quit_ind = quit_ind
        self.payin_message = payin_message
        print("Vending machine operating... \n \n")

    def print_summary(self):
        """
        Print summary of all the money in the vending machine
        """
        print("Machine's current stock: \n",
              self.stock[0], "nickels \n",
              self.stock[1], "dimes \n",
              self.stock[2], "quarters \n",
              self.stock[3], "one dollar bills \n",
              self.stock[4], "five dollar bills \n")
        # compute total value of machine stock
        stock_value = sum(np.array([5, 10, 25, 100, 500]) * self.stock)/100
        print("Total value:", stock_value, "dollars")

    def valid_price(self, price_str: str) -> int:
        """
        Convert price string from input into an int number of cents
        Simultaneously check whether input is valid (div. by 5 cents)
        If not, raise informative errors for appropriate failure case
        """
        try:
            # rounding to nearest cent to avoid float precision errors
            # this technically introduces some in accuracy; can fix by
            #     parsing more fully as text; but this works for demonstration
            price = round(float(price_str) * 100)
            if price % 5 == 0:
                return price
            else:
                raise NotDivisibleError
        except ValueError:
            raise NotFloatError

    def get_price(self) -> int:
        """
        Prompt user for a price
        Once they have entered a valid price, return as an int number of cents
        Valid price syntax: "xx.xx"
        """
        # indicator that a valid price has been entered
        have_price = False
        # gather valid price
        while not have_price:
            # prompt user for price
            price_str = input(
                    "Enter an item price (xx.xx) \n 'q' to quit \n"
                    )
            # quit if user wants to quit
            if price_str.strip().upper() == "Q":
                self.quit_ind = True
                break
            # check whether price is valid
            try:
                price = self.valid_price(price_str)
                have_price = True
            except NotFloatError:
                print("Please enter a numeric price (xx.xx) \n")
            except NotDivisibleError:
                print("No pennies--prices must be multiples of .05 \n")
        # set things to avoid errors if user quits
        if self.quit_ind:
            price = 0
        # if user does not quit, output (decimal) price and return (cent) price
        if not self.quit_ind:
            print("You have selected an item costing", price/100, "dollars \n")
        return(price)


    def init_payin_message(self):
        """
        Print payin instructions
        (Updates flag to print this message to False since it should only
            print once per payin state))
        """
        print("Payment types accepted: \n" +
              "'n' for nickel \n" +
              "'d' for dime \n" +
              "'q' for quarter \n" +
              "'o' for one dollar bill \n" +
              "'f' for five dollar bill \n" +
              "'c' to cancel transaction \n"
              )
        self.payin_message = False

    def valid_payin(self, payin_str: str) -> str:
        """
        Check whether input is valid (n, d, q, o, f, c)
        If not, raise informative error
        If so, output payin value
        """
        if payin_str.upper() in ['N', 'D', 'Q', 'O', 'F', 'C']:
            return payin_str.lower()
        else:
            raise NotPayinError

    def get_payin(self) -> str:
        """
        Prompt user for payin
        Check that it is valid
        Return payin value
        """
        # indicator that a valid payin has been entered
        have_payin = False
        # gather valid payin
        while not have_payin:
            # prompt user for payin
            payin_str = input("Insert payment: \n")
            # check whether payin is valid
            try:
                payin = self.valid_payin(payin_str)
                have_payin = True
            except NotPayinError:
                print("Please enter a valid payment type. \n")
        # once valid payin gathered, return it
        return(payin)

    def update_balance(self, payin: str):
        """
        Reduce the remaining balance by payin
        Increase amount paid by payin
        Adjust the machine's stock
        """
        # find which type of currency user paid in
        stock_labels = ["n", "d", "q", "o", "f"]
        ind_payin = stock_labels.index(payin)
        # subtract value of payin from payin balance
        stock_values = [5, 10, 25, 100, 500]
        self.balance_in -= stock_values[ind_payin]
        # add value of payin to amount paid
        self.amount_paid += stock_values[ind_payin]
        # add payin unit to the stock
        self.stock[ind_payin] += 1

    def pay_out(self, balance: float) -> np.array:
        """
        Given a remaining balance and stock:
        - Check if sufficient balance in coins remains
        - If not, raise OutOfChangeError
        - If so, calculate payout vector and update stock
        """
        # check if sufficient balance remains in coins
        coin_values = np.array([5, 10, 25, 0, 0])
        stock_value = sum(self.stock * coin_values)
        # if not, raise informative error
        if stock_value < balance:
            raise OutOfChangeError
        # if so, calculate payout vector, then pay out
        if stock_value >= balance:
            # initialize balance paid out and stock of coins paid out
            balance_accounted = 0
            stock_payout = np.array([0, 0, 0])
            # starting with quarters and moving to nickels:
            #   - check that this type of coin remains in the stock
            #   - if so, find largest number of this coin that can be paid out
            #   - then pass to next smallest coin
            for i in [2, 1, 0]:
                if self.stock[i] > 0:
                    num_coins = 0
                    value_coins = 0
                    for j in range(0, self.stock[i]):
                        k = j + 1
                        if k * coin_values[i] <= balance - balance_accounted:
                            num_coins = k
                            value_coins = coin_values[i] * k
                    self.stock[i] -= num_coins
                    stock_payout[i] += num_coins
                    balance_accounted += value_coins
            # if balance remains (i.e. out of small coins to make exact change)
            # then manually output change given here
            # so that we can raise informative error
            # (note that machine's stock has been correctly updated above)
            if balance > 0:
                if sum(stock_payout) > 0:
                    print("Please take your change: \n",
                          stock_payout[2], "quarters,",
                          stock_payout[1], "dimes,",
                          stock_payout[0], "nickels \n")
                raise OutOfChangeError
        # return payout vector
        return(stock_payout)

    def run(self):
        """
        Function to make the vending machine actually do something.
        Takes state as input, then follows behavior appropriate to state.
        Note: state can be derived from the balance variables, but is
            explicitly spelled out here for clarity.
        """
        # prompt state:
        #   - prompt user for price
        #   - user can quit
        #   - if they don't, pass price and enter payin state
        if self.state == "prompt":
            # prompt user for price
            price = self.get_price()
            # if user does not want to quit:
            if not self.quit_ind:
                # pass price to balance_in and move to pay-in behavior
                self.balance_in = price
                self.state = "payin"
                self.payin_message = True
                self.run()
            elif self.quit_ind:
                # if user does want to quit, print summary and quit
                print("Final summary: \n")
                self.print_summary()
                print("Vending machine ceased operating.")
        # payin state
        #   - prompt user to pay in a coin or bill
        #   - each time they do, update payin balance and machine stock
        #   - user can cancel transaction
        #   - after full balance paid or cancel, pass change to be paid
        #        to payout balance and enter payout state
        elif self.state == "payin":
            # first time through each payin, give explanatory menu
            if self.payin_message:
                self.init_payin_message()
            # give remaining balance
            print("Remaining balance:", self.balance_in/100, "dollars")
            # prompt user for payin
            payin = self.get_payin()
            # if user did not cancel, adjust balance and stock
            if not payin == 'c':
                self.update_balance(payin)
                # if remaining balance, go to next payin
                # else, pass payin to payout, then go to payout phase
                if self.balance_in > 0:
                    self.run()
                else:
                    self.balance_out = -self.balance_in
                    self.amount_paid = 0
                    self.balance_in = 0
                    self.state = "payout"
                    self.run()
            # if user canceled, transfer balance paid to payout
            if payin == 'c':
                self.balance_out = self.amount_paid
                self.balance_in = 0
                self.amount_paid = 0
                self.state = "payout"
                self.run()
        # payout state
        #   - calculate payout vector and pay out change
        #   - if not enough change: reserve change by not paying out,
        #       direct user to manager for refund
        #   - if not exact change because lacking small coins: pay out
        #       what machine can, then direct to manager for remaining refund
        #   - print summary of machine's contents
        #   - enter prompt state
        elif self.state == "payout":
            try:
                payout = self.pay_out(balance=self.balance_out)
            except OutOfChangeError:
                print("Out of change! \n",
                      "Please see the manager for a refund of",
                      self.balance_out/100, "dollars.")
                self.print_summary()
                self.balance_out = 0
                self.state = "prompt"
                self.run()
            else:
                if sum(payout) > 0:
                    print("Please take your change: \n",
                          payout[2], "quarters,",
                          payout[1], "dimes,",
                          payout[0], "nickels \n")
                else:
                    print("Paid with exact change. \n")
                self.print_summary()
                self.state = "prompt"
                self.run()


def main():
    """
    Demonstrate vending machine program:
        - Initialize VendingMachine with a stock of coins.
        - VendingMachine runs from there.
    """
    vend = VendingMachine(stock=[25, 25, 25, 0, 0])
    vend.run()


if __name__ == "__main__":
    main()
