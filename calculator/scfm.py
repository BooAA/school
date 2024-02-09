import math


class Stack():
    def __init__(self):
        self.items = []

    def push(self, element):
        self.items.append(element)

    def pop(self):
        try:
            del self.items[-1]
        except IndexError:
            print("Try to pop empty stack")

    def top(self):
        try:
            return self.items[-1]
        except IndexError:
            print("Trying to access empty stack")

    def empty(self):
        return len(self.items) == 0

    def __len__(self):
        return len(self.items)

    def __str__(self):
        s = ''
        for e in reversed(self.items):
            s += f'| {str(e)} |\n'
        return s


class Token:
    # user should specify symbols with corresponding priority by
    # explicitly using this variable
    priority_table = {}

    def __init__(self, s):
        self.text = s
        if s in self.priority_table.keys():
            self.priority = self.priority_table[s]
            self.type = 'operator'
        elif s == '(':
            self.priority = -math.inf
            self.type = 'left paren'
        elif s == ')':
            self.priority = -math.inf
            self.type = 'right paren'
        else:
            self.priority = None
            self.type = 'operand'

    def __str__(self):
        return f'{self.text}({self.type}): priority {self.priority}'

    __repr__ = __str__


class Parser:
    def parse(self, expr):
        """ 
        A parser transfer valid infix form to postfix one
        
        expr: valid infix expression with string type
        """
        tokens = [Token(t) for t in expr.split()]
        stack = Stack()
        prefix = []
        
        # Different cases for handling different type of symbols
        # operand: directly add to PREFIX
        # left paren: directly push to stack
        # right paren: keep poping elements to PREFIX until finding a left paren
        # operator: keep poping the elements uniti find a operator with smaller priority
        # Finally, pop everything remain in the stack to PREFIX
        for t in tokens:
            if t.type == 'operand':
                prefix.append(t)
            elif t.type == 'left paren':
                stack.push(t)
            elif t.type == 'right paren':
                while not stack.top().type == 'left paren':
                    prefix.append(stack.top())
                    stack.pop()
                stack.pop()
            elif t.type == 'operator':
                if stack.empty() or t.priority > stack.top().priority:
                    stack.push(t)
                else:
                    while not stack.empty() and stack.top().priority >= t.priority:
                        prefix.append(stack.top())
                        stack.pop()
                    stack.push(t)
        while not stack.empty():
            prefix.append(stack.top())
            stack.pop()
        return prefix


class Evaluator:
    def __init__(self, semantics):
        self.semantics = semantics

    def eval(self, form):
        stack = Stack()
        for token in form:
            if token.type == 'operand':
                try:
                    stack.push(self.semantics[True](token.text))
                except Exception:
                    print(f'unable to eval {token.type} {token.text}')
            elif token.type == 'operator':
                operand2 = stack.top()
                stack.pop()
                operand1 = stack.top()
                stack.pop()
                try:
                    stack.push(self.semantics[token.text](operand1, operand2))
                except Exception:
                    print(f'unable to eval {token.text}({operand1}, {operand2})')
        return stack.top()
