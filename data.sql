create or replace function random_int_between(low int ,high int) 
   returns int as
$$
begin
   return floor(random()* (high-low + 1) + low);
end;
$$ language 'plpgsql' STRICT;

create or replace function random_float_between(low float ,high float) 
   returns float as
$$
begin
   return (random()* (high-low) + low);
end;
$$ language 'plpgsql' STRICT;

create or replace function random_string(length integer) returns text as
$$
declare
  chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;
begin
  if length < 0 then
    raise exception 'Given length cannot be less than 0';
  end if;
  for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;

create or replace procedure create_table()
language plpgsql
as
$$
begin
    create table actor (
    a_id int primary key,
    name char(15)
    );

    create table production_company(
    pc_id int primary key,
    name char(10),
    address char (30)
    );

    create table movie (
    m_id int primary key,
    name char(10),
    year int check (year >= 1900 and year <= 2000),
    imdb_score numeric(3, 2) check (imdb_score >= 1 and imdb_score <= 5),
    pc_id int,
    foreign key (pc_id) references production_company(pc_id)
    );

    create table casting (
    m_id int,
    a_id int,
    primary key (m_id, a_id),
    foreign key (m_id) references movie(m_id),
    foreign key (a_id) references actor(a_id)
    );
end;
$$;

create or replace procedure add_data()
language plpgsql
as
$$
declare
    i int;
    j int;
    randints int[];
    randint int;
begin
    for i in 1..300000 loop
        insert into actor(a_id, name) values(i, random_string(15));
    end loop;

    raise info 'Actors: Done!';

    for i in 1..80000 loop
        insert into production_company(pc_id, name, address) values(i, random_string(10), random_string(30));
    end loop;

    raise info 'Production Company: Done!';

    -- Even & Odd
    for i in 1..1000000 loop
        if random()<0.90 then
            insert into movie(m_id, name, year, imdb_score, pc_id) values(i, random_string(10), random_int_between(1900, 2000), random_float_between(1, 5), random_int_between(1, 500));
        else
            insert into movie(m_id, name, year, imdb_score, pc_id) values(i, random_string(10), random_int_between(1900, 2000), random_float_between(1, 5), random_int_between(501, 80000));
        end if;
    end loop;

    raise info 'Movie: Done!';

    for i in 1..1000000 loop
        randints = '{0,0,0,0}';
        for j in 1..4 loop
            if random()<0.95 then
                randint = random_int_between(1, 10000);
                while randint = any(randints) loop
                    randint = random_int_between(1, 10000);
                end loop;
                insert into casting(m_id, a_id) values(i, randint);
                randints[j] = randint;
            else
                randint = random_int_between(10001, 300000);
                while randint = any(randints) loop
                    randint = random_int_between(10001, 300000);
                end loop;
                insert into casting(m_id, a_id) values(i, randint);
                randints[j] = randint;
            end if;
        end loop;
    end loop;

    raise info 'Casting: Done!';
end;
$$;
