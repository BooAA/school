import scfm


def add(a, b):
    return a + b


def sub(a, b):
    return a - b


def mul(a, b):
    return a * b


def div(a, b):
    return a / b


if __name__ == '__main__':
    
    scfm.Token.priority_table['+'] = 0
    scfm.Token.priority_table['-'] = 0
    scfm.Token.priority_table['*'] = 1
    scfm.Token.priority_table['/'] = 1
    
    parser = scfm.Parser()
    
    calculator = scfm.Evaluator(
        {
            '+': add,
            '-': sub,
            '*': mul,
            '/': div,
            True: float
        }
    )
    
    while True:
        expr = input("calc: ")
        if expr == 'quit':
            break
        RPN_form = parser.parse(expr)
        result = calculator.eval(RPN_form)
        print(f'-> {result}')

    print('Leave calculator')
