import java.io.*;
import java.util.Scanner;


public class DictionaryConverter {
	
	public static void main(String [] args) throws IOException
	{
		FileReader buffer = new FileReader("dictionary.txt");
		FileWriter output = new FileWriter("dictionary2.txt");
		FileWriter output9 = new FileWriter("dictionary9.txt");
		Scanner input = new Scanner(buffer);
		String wordLine = null;
		
		
		while(input.hasNextLine())
		{
			wordLine = input.nextLine();
			if(wordLine.length()>=4 && wordLine.length()<=9)
			{
				output.write(wordLine);
				if(wordLine.length()==4)
					output.write("&&&&&&");
				else if(wordLine.length()==5)
					output.write("&&&&&");
				else if(wordLine.length()==6)
					output.write("&&&&");
				else if(wordLine.length()==7)
					output.write("&&&");
				else if(wordLine.length()==8)
					output.write("&&");
				else if(wordLine.length()==9)
				{
					output.write("&");
					output9.write(wordLine+"&");
				}
			}
		}
		output.close();
		output9.close();
		System.out.println("Done");
	}
}
