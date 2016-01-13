function  line =  pls(pt_x, pt_y, w)
% pt_x  x coordinate
% pt_y  y coordinate
% w     weighting factor


pt_x = pt_x(:);
pt_y = pt_y(:);
w    = w(:);


% step 1: calculate n
n = sum(w(:));

% step 2: calculate weighted coordinates 
y_square = pt_y(:).*pt_y(:);
x_square = pt_x(:).*pt_x(:);
x_square_weighted = x_square.*w;  
y_square_weighted = y_square.*w;  
x_weighted        = pt_x.*w;
y_weighted        = pt_y.*w;

% step 3: calculate the formula
B_upleft = sum(y_square_weighted)-sum(y_weighted).^2/n;
B_upright = sum(x_square_weighted)-sum(x_weighted).^2/n;
B_down = sum(x_weighted(:))*sum(y_weighted(:))/n-sum(x_weighted.*pt_y);
B = 0.5*(B_upleft-B_upright)/B_down;

% step 4: calculate b
if B<0
    b       = -B+sqrt(B.^2+1);
else
    b       = -B-sqrt(B.^2+1);
end

% Step 5: calculate a
a = (sum(y_weighted)-b*sum(x_weighted))/n;

% Step 6: the model is y = a + bx, and now we transform the model to 
% a*x + b*y + c = 0;
c_ = a;
a_ = b;
b_ = -1;

line = [a_ b_ c_];