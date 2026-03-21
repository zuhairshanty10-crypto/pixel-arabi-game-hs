using System;
using System.Drawing;

class Program {
    static void Main() {
        try {
            Image img = Image.FromFile(@"C:\Users\User\Desktop\pixel arabi game hs\assets\player\Ledge_Grab.png");
            Console.WriteLine($"Width: {img.Width}, Height: {img.Height}");
        } catch (Exception ex) {
            Console.WriteLine(ex.Message);
        }
    }
}
