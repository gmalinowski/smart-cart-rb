SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: friendships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendships (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    friend_id uuid NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT friendships_no_self_reference CHECK ((user_id <> friend_id))
);


--
-- Name: group_shopping_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_shopping_lists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    group_id uuid NOT NULL,
    shopping_list_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    owner_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: invitation_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitation_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token uuid DEFAULT gen_random_uuid() NOT NULL,
    max_uses integer DEFAULT 1 NOT NULL,
    uses_count integer DEFAULT 0 NOT NULL,
    expires_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP + '30 days'::interval) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    invitation_type integer DEFAULT 0 NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: shopping_list_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopping_list_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    shopping_list_id uuid NOT NULL,
    name text,
    unit integer DEFAULT 0,
    quantity numeric(8,2) DEFAULT 0.0,
    checked boolean DEFAULT false NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    category integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: shopping_list_public_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopping_list_public_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    shopping_list_id uuid NOT NULL,
    created_by_id uuid NOT NULL,
    permission integer DEFAULT 0 NOT NULL,
    share_token character varying DEFAULT '81615d78-8a43-4ae0-9425-69e157c3f23b'::character varying NOT NULL,
    expires_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: shopping_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopping_lists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_id uuid NOT NULL,
    name character varying NOT NULL,
    note text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_friends_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.user_friends_view AS
 SELECT friendships.user_id,
    friendships.friend_id,
    friendships.created_at,
    friendships.updated_at
   FROM public.friendships
  WHERE (friendships.status = 1)
UNION
 SELECT friendships.friend_id AS user_id,
    friendships.user_id AS friend_id,
    friendships.created_at,
    friendships.updated_at
   FROM public.friendships
  WHERE (friendships.status = 1);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    confirmation_token character varying,
    confirmed_at timestamp(6) without time zone,
    confirmation_sent_at timestamp(6) without time zone,
    unconfirmed_email character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    session_version integer DEFAULT 1 NOT NULL
);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: friendships friendships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_pkey PRIMARY KEY (id);


--
-- Name: group_shopping_lists group_shopping_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_shopping_lists
    ADD CONSTRAINT group_shopping_lists_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: invitation_links invitation_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitation_links
    ADD CONSTRAINT invitation_links_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: shopping_list_items shopping_list_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopping_list_items
    ADD CONSTRAINT shopping_list_items_pkey PRIMARY KEY (id);


--
-- Name: shopping_list_public_links shopping_list_public_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopping_list_public_links
    ADD CONSTRAINT shopping_list_public_links_pkey PRIMARY KEY (id);


--
-- Name: shopping_lists shopping_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopping_lists
    ADD CONSTRAINT shopping_lists_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_friendships_on_friend_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendships_on_friend_id ON public.friendships USING btree (friend_id);


--
-- Name: index_friendships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendships_on_user_id ON public.friendships USING btree (user_id);


--
-- Name: index_friendships_on_user_id_and_friend_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendships_on_user_id_and_friend_id ON public.friendships USING btree (user_id, friend_id);


--
-- Name: index_group_shopping_lists_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_shopping_lists_on_group_id ON public.group_shopping_lists USING btree (group_id);


--
-- Name: index_group_shopping_lists_on_group_id_and_shopping_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_group_shopping_lists_on_group_id_and_shopping_list_id ON public.group_shopping_lists USING btree (group_id, shopping_list_id);


--
-- Name: index_group_shopping_lists_on_shopping_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_shopping_lists_on_shopping_list_id ON public.group_shopping_lists USING btree (shopping_list_id);


--
-- Name: index_groups_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_owner_id ON public.groups USING btree (owner_id);


--
-- Name: index_invitation_links_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_invitation_links_on_token ON public.invitation_links USING btree (token);


--
-- Name: index_invitation_links_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invitation_links_on_user_id ON public.invitation_links USING btree (user_id);


--
-- Name: index_invitation_links_on_user_id_and_recipient_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_invitation_links_on_user_id_and_recipient_email ON public.invitation_links USING btree (user_id, ((metadata ->> 'recipient_email'::text))) WHERE (((metadata ->> 'recipient_email'::text) IS NOT NULL) AND (invitation_type = 1));


--
-- Name: index_shopping_list_items_on_shopping_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shopping_list_items_on_shopping_list_id ON public.shopping_list_items USING btree (shopping_list_id);


--
-- Name: index_shopping_list_public_links_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shopping_list_public_links_on_created_by_id ON public.shopping_list_public_links USING btree (created_by_id);


--
-- Name: index_shopping_list_public_links_on_share_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_shopping_list_public_links_on_share_token ON public.shopping_list_public_links USING btree (share_token);


--
-- Name: index_shopping_list_public_links_on_shopping_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shopping_list_public_links_on_shopping_list_id ON public.shopping_list_public_links USING btree (shopping_list_id);


--
-- Name: index_shopping_lists_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shopping_lists_on_owner_id ON public.shopping_lists USING btree (owner_id);


--
-- Name: index_unique_symmetric_friendships; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_unique_symmetric_friendships ON public.friendships USING btree (LEAST((user_id)::text, (friend_id)::text), GREATEST((user_id)::text, (friend_id)::text));


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: shopping_list_public_links fk_rails_332a8a9b66; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopping_list_public_links
    ADD CONSTRAINT fk_rails_332a8a9b66 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: groups fk_rails_5447bdb9c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_rails_5447bdb9c5 FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: group_shopping_lists fk_rails_67c210134d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_shopping_lists
    ADD CONSTRAINT fk_rails_67c210134d FOREIGN KEY (shopping_list_id) REFERENCES public.shopping_lists(id) ON DELETE CASCADE;


--
-- Name: shopping_lists fk_rails_83badc8e20; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopping_lists
    ADD CONSTRAINT fk_rails_83badc8e20 FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: invitation_links fk_rails_b8af3b9f6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitation_links
    ADD CONSTRAINT fk_rails_b8af3b9f6c FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: shopping_list_items fk_rails_cae3153540; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopping_list_items
    ADD CONSTRAINT fk_rails_cae3153540 FOREIGN KEY (shopping_list_id) REFERENCES public.shopping_lists(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_shopping_lists fk_rails_cfa4851047; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_shopping_lists
    ADD CONSTRAINT fk_rails_cfa4851047 FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: friendships fk_rails_d78dc9c7fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT fk_rails_d78dc9c7fd FOREIGN KEY (friend_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: shopping_list_public_links fk_rails_d7dff06b76; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopping_list_public_links
    ADD CONSTRAINT fk_rails_d7dff06b76 FOREIGN KEY (shopping_list_id) REFERENCES public.shopping_lists(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: friendships fk_rails_e3733b59b7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT fk_rails_e3733b59b7 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260403175316'),
('20260331091351'),
('20260329211344'),
('20260329200453'),
('20260328155409'),
('20260328135000'),
('20260328113010'),
('20260328110817'),
('20260326143540'),
('20260324130620'),
('20260323103253'),
('20260320155650'),
('20260317120735'),
('20260317113739'),
('20260315202752'),
('20260315195026'),
('20260315195025');

